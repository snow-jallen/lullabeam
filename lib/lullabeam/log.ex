defmodule Lullabeam.Log do
  require Logger

  defmacro __using__(_) do
    quote do
      import Lullabeam.Log, only: [log: 1, log: 2]
    end
  end

  def log(data, level \\ :info) do
    require Logger
    msg = inspect(data)
    case level do
      :info -> Logger.info(msg)
      :debug -> Logger.debug(msg)
    end
  end

end
