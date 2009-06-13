#!/usr/bin/env ruby

require 'xmms_adapter'
require 'utils'

xmms = XmmsAdapter.new

trap('INT') { shutdown = true }

until shutdown

  sleep 10

  # skip tracks that played 10 min
  duration = xmms.list(1, 0).first[:duration]
  xmms.skip if duration > 10 * 60 * 1000 && xmms.track_ttl < duration - 10 * 60 * 1000 

  # add a song if playlist doesn't contain at least 3 entries
  if xmms.list.size < 3
    Utils::mix_in_our_stuff(xmms)
  end

end

