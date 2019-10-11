defmodule Lullabeam.Library do
  @moduledoc """
  Works with a data structure representing a library of music, structured
  as follows:

    %{
      sleep: [
        {"/peaceful_sounds",
          [
            "/peaceful_sounds/waves.mp3",
            "/peaceful_sounds/storm.mp3",
            "/peaceful_sounds/amoebae.mp3"
          ]
        },
      ],
      wake: [
        {"/music/good",
          [
            "/music/good/horns.mp3",
            "/music/good/drums.mp3",
            "/music/good/bass.mp3"
          ]
        },
        {"/music/bad",
          [
            "/music/bad/saw.mp3",
            "/music/bad/foghorn.mp3",
            "/music/bad/vomit.mp3"
          ]
        }
      ]
    }
  """

  @doc """
  Given a library, gets the track matching the given playlist and track number.
  Loops playlists and tracks if the numbers given are too large, so that
  playlist and track number can be incremented indefinitely.
  """
  def get_track(library, top_level_folder, playlist_number, track_number) do
    with {:top_level_folder, {:ok, folder}} <-
           {:top_level_folder, Map.fetch(library, top_level_folder)},
         {:playlist_count, f_count} when f_count > 0 <- {:playlist_count, Enum.count(folder)},
         {:playlist_index, f_index} <- {:playlist_index, rem(playlist_number, f_count)},
         {:playlist, {_folder, tracks}} <- {:playlist, Enum.at(folder, f_index)},
         {:track_count, t_count} when t_count > 0 <- {:track_count, Enum.count(tracks)},
         {:track_index, t_index} <- {:track_index, rem(track_number, t_count)},
         {:track, track} when not is_nil(track) <- {:track, Enum.at(tracks, t_index)} do
      {:ok, track}
    else
      err -> {:error, err}
    end
  end
end
