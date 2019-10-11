defmodule Lullabeam.RuntimeSupervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  def init(env) do
    Supervisor.init(children(env), strategy: :rest_for_one)
  end

  def children(:host = env) do
    [
      {Lullabeam.LibraryMonitor, env},
      {Lullabeam.DJ, env},
      {Lullabeam.Debouncer, env},
      {Lullabeam.StartupSounder, env}
    ]
  end

  def children(:lullabeam_rpi3 = env) do
    [
      {Lullabeam.LibraryMonitor, env},
      {Lullabeam.DJ, env},
      {Lullabeam.Debouncer, env},
      {
        Lullabeam.InputWatcher,
        [device_adapter: Lullabeam.InputDevices.JellyCombKeypad]
      },
      {Lullabeam.StartupSounder, env}
    ]
  end
end
