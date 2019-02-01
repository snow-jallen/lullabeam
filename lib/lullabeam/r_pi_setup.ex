defmodule Lullabeam.RPiSetup do
  @moduledoc """
  To run only on the target RPi.
  Blocks in `init` because the rest of the system shouldn't try to play music
  until this is done.
  """
  use GenServer
  use Lullabeam.Log

  def start_link(_env) do
    GenServer.start_link(__MODULE__, %{})
  end

  @impl true
  def init(state) do
    wait_for_sound_card_to_be_enabled()
    set_audio_output_to_headphone_jack()
    set_volume_to_headphone_safe_level()
    {:ok, state}
  end

  defp wait_for_sound_card_to_be_enabled do
    wait_for_sound_card_to_be_enabled(0)
  end

  defp wait_for_sound_card_to_be_enabled(tries) when tries > 50 do
    raise "sound card not available"
  end

  defp wait_for_sound_card_to_be_enabled(tries) do
    output = :os.cmd('amixer scontrols') |> to_string

    if String.match?(output, ~r/PCM/) do
      :ok
    else
      log("Waiting for sound card to be enabled...")
      :timer.sleep(500)
      wait_for_sound_card_to_be_enabled(tries + 1)
    end
  end

  defp set_audio_output_to_headphone_jack() do
    {_ret_string, 0} = System.cmd("amixer", ["cset", "numid=3", "1"])
    log("Set audio to headphone jack")
  end

  defp set_volume_to_headphone_safe_level() do
    {_ret_string, 0} = System.cmd("amixer", ["sset", "PCM", "70%"])
    log("Set volume to headphone safe level")
  end
end
