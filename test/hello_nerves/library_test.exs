defmodule Hello.LibraryTest do
  use ExUnit.Case
  doctest Lullabeam.Library
  alias Lullabeam.Library

  def fake_library do
    [
      {"/music/good",
       [
         "/music/good/horns.mp3",
         "/music/good/drums.mp3",
         "/music/good/bass.mp3"
       ]},
      {"/music/bad",
       [
         "/music/bad/howl.mp3",
         "/music/bad/splat.mp3"
       ]}
    ]
  end

  test "can get folder 0, track 0" do
    assert Library.get_track(fake_library(), 0, 0) == {:ok, "/music/good/horns.mp3"}
  end

  test "can get playlist 0, track 1" do
    assert Library.get_track(fake_library(), 0, 1) == {:ok, "/music/good/drums.mp3"}
  end

  test "can get playlist 1, track 0" do
    assert Library.get_track(fake_library(), 1, 0) == {:ok, "/music/bad/howl.mp3"}
  end

  test "loops playlists when the playlist number is out of bounds" do
    assert Library.get_track(fake_library(), 2, 0) == assert Library.get_track(fake_library(), 0, 0)
  end

  test "loops tracks when the track number is out of bounds" do
    assert Library.get_track(fake_library(), 0, 3) == assert Library.get_track(fake_library(), 0, 0)
  end
end
