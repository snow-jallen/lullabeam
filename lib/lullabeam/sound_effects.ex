defmodule Lullabeam.SoundEffects do
  def play(env, effect_name) do
    port =
      Port.open(
        {:spawn_executable, effects_player(env)},
        [
          :stderr_to_stdout,
          args: [
            Path.join([:code.priv_dir(:lullabeam), file_for(effect_name)])
          ]
        ]
      )
  end

  defp file_for(:startup), do: "startup.wav"
  defp file_for(:error), do: "error.wav"

  defp effects_player(:host), do: "/usr/local/homebrew/bin/play" # `brew install sox`
  defp effects_player(_target), do: "/usr/bin/aplay"
end
