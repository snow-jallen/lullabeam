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
  def set_bed_timer(:nap), do: cmd({:set_timer, :bed})
  def set_nap_timer(:nap), do: cmd({:set_timer, :nap})

  defp cmd(cmd), do: Lullabeam.Debouncer.debounce(cmd)
end
