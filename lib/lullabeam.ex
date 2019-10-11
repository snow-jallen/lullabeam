defmodule Lullabeam do
  @moduledoc """
  Elixir + Nerves Lullaby player. Top-level control functions here.
  """

  def play_or_pause, do: cmd(:play_or_pause)
  def stop, do: cmd(:stop)
  def next_track, do: cmd(:next_track)
  def prev_track, do: cmd(:prev_track)
  def next_folder, do: cmd(:next_folder)
  def prev_folder, do: cmd(:prev_folder)
  def set_mode(:nap), do: cmd({:set_mode, :nap})
  def set_mode(:bed), do: cmd({:set_mode, :bed})
  def set_mode(:wake), do: cmd({:set_mode, :wake})

  defp cmd(cmd), do: Lullabeam.Debouncer.debounce(cmd)
end
