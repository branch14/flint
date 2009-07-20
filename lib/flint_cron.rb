#!/usr/bin/env ruby

puts "starting up, please stand by..."

require File.join(File.dirname(__FILE__), 'xmms_adapter')
require File.join(File.dirname(__FILE__), 'utils')

$shutdown = false
$pause = 10

# register Ctrl-C
trap('INT') do
  puts 'shutting down, please stand by...'
  $shutdown = true
end

xmms = XmmsAdapter.new

# start the xmms2d if nescessary ???
# xmms.play

# 10 minutes in milliseconds
_10min = 10 * 60 * 1000

until $shutdown

  # sleep 10 seconds
  sleep $pause

  puts "check at #{Time.now.strftime('%H:%M:%S')}"

  list = xmms.list
  
  if list.size > 0
    # skip tracks that played 10 min
    duration = list.first[:duration]
    if duration > _10min && xmms.track_ttl < duration - _10min
      puts "skipping to next song"
      xmms.skip 
    end
  end

  # add a song if playlist doesn't contain at least 3 entries
  if list.size < 3
    puts "running out of tracks, mixing in our stuff!" 
    puts Utils.mix_in_our_stuff(xmms) 
    # start the xmms2d if nescessary
    xmms.play
  end

end

