defmodule Lullabeam.FileUtilTest do
  use ExUnit.Case
  doctest Lullabeam.FileUtil
  alias Lullabeam.FileUtil

  describe "organize/1" do
    test "organizes files into sleep and wake and then by subfolder" do
      files = [
        "/sleep/a/apple.mp3",
        "/sleep/a/ant.mp3",
        "/sleep/b/bat.mp3",
        "/sleep/b/boat.mp3",
        "/wake/c/cat.mp3",
        "/wake/d/dingo.mp3",
        "/wake/d/duck.mp3"
      ]

      organized = FileUtil.organize(files, "/")

      assert organized == %{
               sleep: [
                 {"/sleep/a", ["/sleep/a/apple.mp3", "/sleep/a/ant.mp3"]},
                 {"/sleep/b", ["/sleep/b/bat.mp3", "/sleep/b/boat.mp3"]}
               ],
               wake: [
                 {"/wake/c", ["/wake/c/cat.mp3"]},
                 {"/wake/d", ["/wake/d/dingo.mp3", "/wake/d/duck.mp3"]}
               ]
             }
    end
  end

  test "ensures that top-level folders exist" do
    files = []
    organized = FileUtil.organize(files, "/")

    assert organized == %{
             sleep: [],
             wake: []
           }
  end

  test "can find sleep and wake subfolders within a base folder" do
    files = [
      "/some/music/folder/sleep/a/apple.mp3",
      "/some/music/folder/sleep/a/ant.mp3",
      "/some/music/folder/sleep/b/bat.mp3",
      "/some/music/folder/sleep/b/boat.mp3",
      "/some/music/folder/wake/c/cat.mp3",
      "/some/music/folder/wake/d/dingo.mp3",
      "/some/music/folder/wake/d/duck.mp3"
    ]

    organized = FileUtil.organize(files, "/some/music/folder")

    assert organized == %{
             sleep: [
               {"/some/music/folder/sleep/a",
                ["/some/music/folder/sleep/a/apple.mp3", "/some/music/folder/sleep/a/ant.mp3"]},
               {"/some/music/folder/sleep/b",
                ["/some/music/folder/sleep/b/bat.mp3", "/some/music/folder/sleep/b/boat.mp3"]}
             ],
             wake: [
               {"/some/music/folder/wake/c", ["/some/music/folder/wake/c/cat.mp3"]},
               {"/some/music/folder/wake/d",
                ["/some/music/folder/wake/d/dingo.mp3", "/some/music/folder/wake/d/duck.mp3"]}
             ]
           }
  end
end
