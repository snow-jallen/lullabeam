#! /bin/sh
### BEGIN INIT INFO
# Provides: lullabeam
# Required-Start:    $all
# Required-Stop: 
# Default-Start:     5 
# Default-Stop:      6 
# Short-Description: Your service description
### END INIT INFO

# Set default audio output to analog jack
amixer cset numid=3 1

# Set audio volume to 400 centi-db (100%)
amixer cset numid=1 400

# start lullabeam
cd /home/pi/git/lullabeam
iex -S mix