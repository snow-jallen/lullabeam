defmodule Lullabeam.LibraryMonitor do
  use GenServer
  alias Lullabeam.{FileUtil, Library}
  use Lullabeam.Log
  @check_interval 5_000

  @moduledoc """
  Searches for music library in expected location(s) and delays startup until
  it is found.

  TODO: After startup, check periodically to see if USB stick is still
  inserted, and crash if not.  The logic attempting this below doesn't
  actually work, presumably because the USB stick doesn't get
  unmounted properly when it's removed.  There are all kinds of errors
  in the console in that case.  Maybe use `udev` to detect thumb drive
  being plugged or unplugged?  See
  https://opensource.com/article/18/11/udev and
  https://unix.stackexchange.com/questions/229987/udev-rule-to-match-any-usb-storage-device
  """

  def start_link(env) do
    GenServer.start_link(__MODULE__, %{env: env}, name: __MODULE__)
  end

  @impl true
  def init(%{env: env} = state) do
    {:ok, library} = FileUtil.music_library(env)
    # Doesn't work - see module docs
    # schedule_library_check()
    {:ok, Map.put(state, :library, library)}
  end

  def library do
    IO.puts "library"
    GenServer.call(__MODULE__, :library)
  end

  @impl true
  def handle_call(:library, _from, state) do
    IO.puts "handle_call :library"
    {:reply, {:ok, state.library}, state}
  end

  @impl true
  def handle_info(:check_library, %{library: library} = state) do
    IO.puts "handle_info :check_library"
    {:ok, track_file} = random_track_from(library)

    if File.exists?(track_file) do
      log("library still there - found #{inspect(track_file)}", :debug)
      schedule_library_check()
      {:noreply, state}
    else
      {:stop, {:error, :missing_library_file, track_file}, state}
    end
  end

  defp schedule_library_check() do
    IO.puts "schedule_library_check"
    Process.send_after(self(), :check_library, @check_interval)
  end

  defp random_track_from(library) do
    IO.puts "random_track_from"
    Library.get_track(
      library,
      :rand.uniform(100),
      :rand.uniform(100)
    )
  end
end
