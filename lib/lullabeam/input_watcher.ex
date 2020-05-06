defmodule Lullabeam.InputWatcher do
  @moduledoc """
  Delays startup until finds input device; after that, receives input and
  passes it along to the rest of the system.
  """
  use GenServer
  use Lullabeam.Log
  alias Lullabeam.Debouncer

  def start_link(device_adapter: device_adapter) do
    GenServer.start_link(__MODULE__, %{device_adapter: device_adapter}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    log("Looking for an input device...")
    :ok = wait_for_input_device(state.device_adapter)
    {:ok, state}
  end

  def wait_for_input_device(device_adapter) do
    with [_ | _] = devices <- Enum.sort(InputEvent.enumerate()),
         device when not is_nil(device) <-
           Enum.find(devices, fn d ->
             elem(d, 1) == device_adapter.device_name()
           end) do
      log("Found input device #{device_adapter.device_name()}!")
      device_path = elem(device, 0)
      {:ok, pid} = InputEvent.start_link(device_path)
      :ok
    else
      _ ->
        log("Don't see an input device yet...")
        :timer.sleep(1_000)
        wait_for_input_device(device_adapter)
    end
  end

  def handle_info({:input_event, _path, events}, %{device_adapter: device_adapter} = state) do
    for {:cmd, cmd} <- Enum.map(events, &device_adapter.interpret/1) do
      log("InputWatcher handle_info #{inspect(cmd)}")
      debounce(cmd)
    end

    {:noreply, state}
  end

  def handle_info(msg, state) do
    log("InputWatcher got message #{inspect(msg)}")
    {:noreply, state}
  end

  @impl true
  def terminate(reason, state) do
    log(["InputWatcher is terminating with reason", reason, "state", state])
    state
  end

  defp debounce(cmd) do
    Debouncer.debounce(cmd)
  end
end
