defmodule Lullabeam.DJ do
  @mpv_socket_path "/tmp/mpv.sock"
  @navigation_cmds [:next_track, :prev_track, :next_folder, :prev_folder]
  @timers %{
    nap: 60 * 20,
    bed: 60 * 45,
    wake: 60 * 60
  }

  use GenServer
  use Lullabeam.Log
  alias Lullabeam.{FileUtil, Library, LibraryMonitor}

  def start_link(env) do
    GenServer.start_link(__MODULE__, %{env: env, playback: %{state: :stopped}}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    # So that if the thumb drive is removed and this process is terminated, it
    # gets to run its terminate/2
    Process.flag(:trap_exit, true)
    {:ok, state, {:continue, :setup}}
  end

  def execute_cmd(cmd) do
    log(["DJ executing cmd", cmd])
    GenServer.call(__MODULE__, cmd)
  end

  @impl true
  def handle_continue(:setup, %{env: env} = state) do
    ensure_mpv_stopped(env)
    {:ok, library} = LibraryMonitor.library()

    updated_state =
      state
      |> Map.put(:library, library)
      |> Map.put(:current_mode, :bed)
      |> Map.put(:max_seconds, @timers.bed)
      |> Map.put(:current_folder, 0)
      |> Map.put(:current_track, 0)
      |> Map.put(:navigating, false)

    {:noreply, updated_state}
  end

  @impl true
  def handle_call(:play_or_pause, _from, %{playback: %{state: :stopped}} = state) do
    log("play or pause - was stopped")

    {:ok, track} =
      Library.get_track(
        state.library,
        playlist_category(state.current_mode),
        state.current_folder,
        state.current_track
      )

    {:ok, _port = play_track(track, state.env)}

    {:reply, :ok, mark_started_playing_now(state)}
  end

  @impl true
  def handle_call(:play_or_pause, _from, %{playback: %{state: :playing}} = state) do
    log("play or pause - was playing")
    :ok = message_mpv(:pause)

    updated_state =
      state
      |> put_in([:playback, :state], :paused)

    {:reply, :ok, updated_state}
  end

  @impl true
  def handle_call(:play_or_pause, _from, %{playback: %{state: :paused}} = state) do
    log("play or pause - was paused")
    :ok = message_mpv(:unpause)

    updated_state =
      state
      |> put_in([:playback, :state], :playing)
      |> mark_started_playing_now()

    {:reply, :ok, updated_state}
  end

  @impl true
  def handle_call(nav_cmd, _from, %{playback: %{state: :paused}} = state)
      when nav_cmd in @navigation_cmds do
    # ignore
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(nav_cmd, _from, %{playback: %{state: :stopped}} = state)
      when nav_cmd in @navigation_cmds do
    updated_state = navigate(state, nav_cmd)
    {:reply, :ok, updated_state}
  end

  @impl true
  def handle_call(nav_cmd, _from, %{playback: %{state: :playing}} = state)
      when nav_cmd in @navigation_cmds do
    # this will trigger a DOWN
    ensure_mpv_stopped(state.env)

    updated_state =
      state
      |> navigate(nav_cmd)
      |> Map.put(:navigating, true)

    {:reply, :ok, updated_state}
  end

  @impl true
  def handle_call(:stop, _from, state) do
    ensure_mpv_stopped(state.env)
    {:reply, :ok, Map.put(state, :playback, %{state: :stopped})}
  end

  @impl true
  def handle_call({:set_mode, new_mode}, _from, state) do
    log("setting mode #{new_mode}")

    new_state =
      case state do
        %{playback: %{state: :playing}} ->
          mark_started_playing_now(state)

        _ ->
          state
      end
      |> maybe_switch_playlist_category(new_mode)
      |> Map.put(:current_mode, new_mode)
      |> Map.put(:max_seconds, Map.fetch!(@timers, new_mode))

    {:reply, :ok, new_state}
  end

  defp maybe_switch_playlist_category(state, new_mode) do
    if playlist_category(state.current_mode) == playlist_category(new_mode) do
      state
    else
      ensure_mpv_stopped(state.env)

      state
      |> navigate(:next_track)
      |> Map.put(:navigating, true)
    end
  end

  @impl true
  def handle_call(msg, _from, state) do
    log("lolwat?! you said '#{msg}'")
    {:reply, :ok, state}
  end

  @impl true
  # _exit_type is :normal even if `kill -9 mpv_pid`
  def handle_info({:DOWN, _ref, :port, _port, _exit_type}, state) do
    state = react_to_mpv_termination(state)
    {:noreply, state}
  end

  @impl true
  def handle_info(_unexpected_msg, state) do
    # ignore
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, %{env: env} = _state) do
    log("terminating DJ - ensuring mpv is stopped")
    ensure_mpv_stopped(env)
  end

  defp react_to_mpv_termination(%{playback: %{state: :playing}} = state) do
    state =
      if state.navigating do
        Map.put(state, :navigating, false)
      else
        navigate(state, :next_track)
      end

    elapsed_seconds = now() - state.playback.started_playing

    if elapsed_seconds >= state.max_seconds do
      log("time to stop! elapsed #{elapsed_seconds} limit #{state.max_seconds}")
      Map.put(state, :playback, %{state: :stopped})
    else
      log("keep playing! elapsed #{elapsed_seconds} limit #{state.max_seconds}")

      {:ok, track} =
        Library.get_track(
          state.library,
          playlist_category(state.current_mode),
          state.current_folder,
          state.current_track
        )

      {:ok, _port = play_track(track, state.env)}

      state
    end
  end

  defp playlist_category(:wake), do: :wake
  defp playlist_category(_), do: :sleep

  defp react_to_mpv_termination(%{playback: %{state: playback_state}} = state)
       when playback_state != :playing do
    # ignore
    state
  end

  defp play_track(filepath, env) do
    log("will play track #{filepath}")

    port =
      Port.open(
        {:spawn_executable, mpv_path(env)},
        [
          :binary,
          :exit_status,
          args: [
            "--no-audio-display",
            "--term-status-msg",
            "",
            ~s[--input-ipc-server=#{@mpv_socket_path}],
            Path.expand(filepath)
          ]
        ]
      )

    wait_for_mpv_to_start(env)
    Port.monitor(port)
    {:ok, port}
  end

  defp now do
    System.monotonic_time(:second)
  end

  defp ensure_mpv_stopped(env) do
    :os.cmd('killall mpv')
    wait_for_mpv_to_stop(env)
  end

  defp wait_for_mpv_to_start(env, tries \\ 0) do
    if tries > 10 do
      raise "mpv is not starting"
    end

    case find_mpv_process(env) do
      [] ->
        log("mpv not started yet")
        :timer.sleep(20)
        wait_for_mpv_to_start(env, tries + 1)

      _ = result ->
        log(["mpv started", result])
        :ok
    end
  end

  defp find_mpv_process(:host) do
    :os.cmd('pgrep mpv')
  end

  defp find_mpv_process(_target) do
    # because pgrep isn't available on the Rpi,
    # but ps has different flags depending on OS
    :os.cmd('ps | grep mpv')
    |> to_string()
    |> String.split("\n")
    |> Enum.reject(fn s ->
      s == "" || String.match?(s, ~r/grep/)
    end)
  end

  defp wait_for_mpv_to_stop(env, tries \\ 0) do
    if tries > 10 do
      raise "mpv is not stopping"
    end

    case find_mpv_process(env) do
      [] ->
        log("mpv stopped")
        :ok

      _ = result ->
        log(["mpv not stopped yet", result])
        :timer.sleep(20)
        wait_for_mpv_to_stop(tries + 1)
    end
  end

  defp message_mpv(msg) do
    msg = translate_for_mpv(msg)
    {:ok, tcp_port} = get_mvp_tcp_port()
    :ok = :gen_tcp.send(tcp_port, msg)
    Port.close(tcp_port)
    :ok
  end

  defp get_mvp_tcp_port, do: get_mvp_tcp_port(0)

  defp get_mvp_tcp_port(tries) when tries > 10 do
    {:error, "gave up trying to connect to mpv"}
  end

  defp get_mvp_tcp_port(tries) do
    case :gen_tcp.connect({:local, @mpv_socket_path}, 0, [:local, :binary]) do
      {:ok, tcp_port} ->
        log("connected to mvp")
        {:ok, tcp_port}

      {:error, :econnrefused} ->
        log("connection refused (mvp not ready yet)")
        :timer.sleep(20)
        get_mvp_tcp_port(tries + 1)

      e ->
        {:error, {"could not connect to mpv", e}}
    end
  end

  defp translate_for_mpv(message) do
    case message do
      :pause -> ~s<{ "command": ["set_property", "pause", true] }\n>
      :unpause -> ~s<{ "command": ["set_property", "pause", false] }\n>
      :quit -> ~s<{ "command": ["quit"] }\n>
    end
  end

  defp navigate(state, :next_track) do
    Map.put(state, :current_track, state.current_track + 1)
  end

  defp navigate(state, :prev_track) do
    Map.put(state, :current_track, state.current_track - 1)
  end

  defp navigate(state, :next_folder) do
    state
    |> Map.put(:current_folder, state.current_folder + 1)
    |> Map.put(:current_track, 0)
  end

  defp navigate(state, :prev_folder) do
    state
    |> Map.put(:current_folder, state.current_folder - 1)
    |> Map.put(:current_track, 0)
  end

  defp mark_started_playing_now(state) do
    Map.put(state, :playback, %{state: :playing, started_playing: now()})
  end

  defp mpv_path(:host), do: "/usr/local/homebrew/bin/mpv"
  defp mpv_path(_target), do: "/usr/bin/mpv"
end
