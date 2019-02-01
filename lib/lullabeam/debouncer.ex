defmodule Lullabeam.Debouncer do
  @moduledoc """
  Debounce input from the keyboard: if buttons are pushed in rapid succession
  (as experience with kids says they will be), ignore them.
  """
  use GenServer
  use Lullabeam.Log
  alias Lullabeam.DJ

  def start_link(env) do
    debounce_ms =
      case env do
        # gives time to tinker from command line
        :host -> 2_000
        # hardware input on the device is faster
        _target -> 200
      end

    GenServer.start_link(__MODULE__, %{status: :listening, cmd: nil, debounce_ms: debounce_ms, env: env},
      name: __MODULE__
    )
  end

  def init(state) do
    {:ok, state}
  end

  def debounce(cmd) do
    GenServer.call(__MODULE__, {:cmd, cmd})
  end

  def handle_call({:cmd, new_cmd}, _from, %{status: :listening} = state) do
    log(["debouncer got cmd that could be legit", new_cmd])
    {:reply, :pending, set_pending(state, new_cmd), state.debounce_ms}
  end

  def handle_call({:cmd, _cmd}, _from, %{status: s} = state) when s != :listening do
    if s == :pending do
      play_error_sound(state.env)
    end
    {:reply, {:error, :slow_down_buddy}, set_blocking(state), state.debounce_ms}
  end

  def handle_info(:timeout, %{status: status, cmd: cmd} = state) do
    case status do
      :pending ->
        log(["debouncer actually_sending along cmd", cmd])
        tell_dj(cmd)

      :blocking ->
        log(["can stop blocking", cmd])
    end

    {:noreply, set_listening(state)}
  end

  def handle_info(_, current_cmd) do
    {:noreply, current_cmd}
  end

  defp tell_dj(cmd) do
    DJ.execute_cmd(cmd)
  end

  defp set_pending(state, cmd) do
    state
    |> Map.put(:status, :pending)
    |> Map.put(:cmd, cmd)
  end

  defp set_blocking(state) do
    state
    |> Map.put(:status, :blocking)
    |> Map.put(:cmd, nil)
  end

  defp set_listening(state) do
    state
    |> Map.put(:status, :listening)
    |> Map.put(:cmd, nil)
  end

  defp play_error_sound(env) do
    Lullabeam.SoundEffects.play(env, :error)
  end
end
