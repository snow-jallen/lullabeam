defmodule Lullabeam.LibraryTest do
  use ExUnit.Case
  doctest Lullabeam.Library
  alias Lullabeam.Library

  def fake_library do
    %{
      sleep: [
        {"/peaceful_sounds",
         [
           "/sleep/peaceful_sounds/waves.mp3",
           "/sleep/peaceful_sounds/storm.mp3",
           "/sleep/peaceful_sounds/amoebae.mp3"
         ]}
      ],
      wake: [
        {"/music/good",
         [
           "/wake/music/good/horns.mp3",
           "/wake/music/good/drums.mp3",
           "/wake/music/good/bass.mp3"
         ]},
        {"/music/bad",
         [
           "/wake/music/bad/howl.mp3",
           "/wake/music/bad/splat.mp3"
         ]}
      ]
    }
  end

  test "can get :wake folder 0, track 0" do
    assert Library.get_track(fake_library(), :wake, 0, 0) == {:ok, "/wake/music/good/horns.mp3"}
  end

  test "can get :wake playlist 0, track 1" do
    assert Library.get_track(fake_library(), :wake, 0, 1) == {:ok, "/wake/music/good/drums.mp3"}
  end

  test "can get :wake playlist 1, track 0" do
    assert Library.get_track(fake_library(), :wake, 1, 0) == {:ok, "/wake/music/bad/howl.mp3"}
  end

  test "loops playlists when the playlist number is out of bounds" do
    assert Library.get_track(fake_library(), :wake, 2, 0) ==
             assert(Library.get_track(fake_library(), :wake, 0, 0))
  end

  test "loops tracks when the track number is out of bounds" do
    assert Library.get_track(fake_library(), :wake, 0, 3) ==
             assert(Library.get_track(fake_library(), :wake, 0, 0))
  end
end
