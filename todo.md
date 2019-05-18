    I have a little Nerves device that plays music off a thumb drive. I explicitly call `mount` on `/dev/sda1` while booting up my application.
    I’d like to be able to freely unplug the thumb drive and plug in a different one while the device is running. I only ever read from it, so it seems like that should be safe. I tried periodically checking `File.exists?/1` on a random music file to see if the drive is still inserted, hoping I could notice that it’s gone and start looking for a new drive to `mount`, but I see all kinds of OS errors and don’t know how to recover after that.
    I do see messages in the console when a drive is plugged in or unplugged, and I read that one can use `udev` to detect this (https://opensource.com/article/18/11/udev), but wondered if there was another way y’all would recommend. (edited)

    fhunleth   [1 hour ago]
    The `uevent` messages that trigger `udev` rules in normal Linux get collected in SystemRegistry. I don't know the keys for filesystem mounts, but the procedure would be to register for events from SystemRegistry and then trigger off the mount/unmount ones. I would expect unmount coming through as a removal event, but I don't know for sure.

    fhunleth   [1 hour ago]
    This is one of those things that I do so rarely that I have to believe there's a much, much better way. However, to figure out what changes, I'd run `SystemRegistry.match(:_)` and save the output to a file in `/root` before and after inserting/removing the USB drive. Then I'd sftp into the Nerves device, download the before and after files and compare them to see what I should try to match.

    gregmefford   [1 hour ago]
    Yeah it would be really handy if SystemRegistry had some better APIs for exploring what kinds of state/messages are available on a running system.

-----

Why can't I properly `mount` and `unmount` and `mount` again successfully?
