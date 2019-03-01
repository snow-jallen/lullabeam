# Lullabeam

Lullabeam runs on an Raspberry Pi 3 and uses [mpv](https://mpv.io/) to play songs off a USB stick for a predetermined amount of time so my kids can fall asleep.
It can also be used as a Pomodoro timer.
It never actually stops a song when the time runs out; it just checks the timer when deciding whether to start another song.

This is a personal project and works for me; it has the features I want and works on the hardware I have.
I'm not interested in contributions and won't have time to help you use it, but feel free to fork it and do what you like with the code. :)

## Features

- "Nap" and "bed" timer settings; whenever a song ends, if the alloted time has run out, the next song doesn't play.
- Supports changing folders, songs, and timer settings via a USB number pad (the specific one I have; make your own module under `Lullabeam.InputDevices` to use a different one). No screen is needed for operation (screens are bad for sleep).
- Plays at a predetermined headphone-safe volume level; external speakers can be used to control volume.
- Expects kids to push the buttons like crazy and ignores them until they calmly press one button at a time
- Sets the device to use minimal power, since playing music is not CPU-intensive
- Because playback is done via [mpv](https://mpv.io/), Lullabeam can play a variety of music file formats. I hard coded a list of file extensions I cared to look for in `Lullabeam.FileUtil`, which finds files on the USB stick, but you could modify that.
- Doesn't connect to a network, so there's no security risk to running it as-is indefinitely

## Formatting the USB stick / thumb drive

"FAT" format seems to work well to be readable on the Pi. Eg, from MacOS 10.14, use Disk Utility format a USB thumb drive as a "master boot record" in format "MS-DOS (FAT)".

The drive must contain a `music` folder. In development, `dev_music` under the project folder will be used; put whatever you want there, as it's ignored by Git.

Each bottom-level folder under the general music folder will be treated as a playlist.
Eg, with music files arranged like this, the playlists would be "lullabies", "jazz/smooth" and "jazz/rough".

    ▾ music/
      ▾ lullabies/
        sleepytimes.mp3
        snoozely.ogg
      ▾ jazz/
        ▾ smooth/
          buttery.mp3
          frictionless.m4a
        ▾ rough/
          prickly.aac
          scratchy.flac

## Logging

`RingLogger.attach` or `.detach` to toggle logging in `iex`

## Development

To build and build new firmware, `export MIX_TARGET=lullabeam_rpi3` in a terminal window and `mix do firmware, firmware.burn` as often as needed.

Plug in a screen to the HDMI port to see debugging output, and plug in a full USB keyboard to tinker with `iex`. `RingLogger.attach / RingLogger.detach` toggles logging output.

## TODO

- Enable hot swapping of USB sticks
- See if keystrokes can be ignored by shell - https://github.com/LeToteTeam/input_event/issues/8
