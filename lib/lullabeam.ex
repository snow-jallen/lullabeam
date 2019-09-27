defmodule Lullabeam do
  @moduledoc """
  Documentation for Lullabeam.
  """

  def cmd(cmd) do
    Lullabeam.Debouncer.debounce(cmd)
  end
end
