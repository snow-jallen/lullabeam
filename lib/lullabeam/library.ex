defmodule Lullabeam.Library do
  @moduledoc """
  Works with libraries structured as a list of folders, each with a list of
  tracks, like:

    [
      {"/music/good",
       [
         "/music/good/horns.mp3",
         "/music/good/drums.mp3",
         "/music/good/bass.mp3"
       ]},
      {"/music/bad",
       [
         "/music/bad/saw.mp3",
         "/music/bad/foghorn.mp3",
         "/music/bad/vomit.mp3"
       ]}
    ]
  """

  @doc """
  Given a library, gets the track matching the given folder and track number.
  Loops folders and tracks if the numbers given are too large, so that folder
  and track number can be incremented indefinitely.
  """
  def get_track(library, folder_number, track_number) do
    with {:folder_count, f_count} when f_count > 0 <- {:folder_count, Enum.count(library)},
         {:folder_index, f_index} <- {:folder_index, rem(folder_number, f_count)},
         {:folder, {_folder, tracks}} <- {:folder, Enum.at(library, f_index)},
         {:track_count, t_count} when t_count > 0 <- {:track_count, Enum.count(tracks)},
         {:track_index, t_index} <- {:track_index, rem(track_number, t_count)},
         {:track, track} when not is_nil(track) <- {:track, Enum.at(tracks, t_index)} do
      {:ok, track}
    else
      err -> {:error, err}
    end
  end
end
