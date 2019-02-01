defmodule Lullabeam.FileUtil do
  use Lullabeam.Log
  @music_file_extensions ~w[aac aiff flac m4a mp3 ogg voc wav]

  def music_library(env) do
    base_dir = root_music_dir_for(env)

    files =
      Path.wildcard("#{base_dir}/**/*.{#{Enum.join(@music_file_extensions, ",")}}")
      |> Enum.group_by(&Path.dirname/1)
      |> Map.to_list()
      |> Enum.reject(fn {_folder_name, tracks} -> Enum.empty?(tracks) end)

    {:ok, files}
  end

  defp root_music_dir_for(:host = env) do
    path = Path.join(File.cwd!(), "dev_music")

    if File.dir?(path) do
      path
    else
      log(
        "don't see #{inspect(path)}; waiting for music folder #{inspect(path)} to be created..."
      )

      :timer.sleep(2_000)
      root_music_dir_for(env)
    end
  end

  defp root_music_dir_for(_linux_target) do
    mounted_thumb_drive_dir()
  end

  defp mounted_thumb_drive_dir do
    if File.dir?("/mnt/music") do
      "/mnt/music"
    else
      {:ok, drive_dir} = wait_for_thumb_drive_to_be_inserted()
      {_, 0} = System.cmd("mount", [drive_dir, "/mnt"])
      mounted_thumb_drive_dir()
    end
  end

  defp wait_for_thumb_drive_to_be_inserted() do
    device_paths = ~w[/dev/sda1 /dev/sdb1]

    drive_dir =
      device_paths
      |> Enum.find(fn dirname ->
        File.exists?(dirname)
      end)

    case drive_dir do
      d when is_binary(d) ->
        log("found thumb drive at #{inspect(d)}")
        {:ok, d}

      nil ->
        log("waiting for thumb drive to be inserted... checked #{inspect(device_paths)}")
        :timer.sleep(2_000)
        wait_for_thumb_drive_to_be_inserted()
    end
  end
end
