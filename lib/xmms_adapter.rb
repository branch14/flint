#!/usr/bin/env ruby 

# apt-get install libxmmsclient-ruby
require 'xmmsclient'

def duration_format(milliseconds)
  minutes = milliseconds / (60 * 1000)
  seconds = (milliseconds / 1000) - (minutes * 60)
  "%s:%02d" % [minutes, seconds]
end


class XmmsAdapter
  
  def initialize
    @xmms = Xmms::Client.new('sub0')
    @xmms.connect(ENV['XMMS_PATH'])
    @playlist = @xmms.playlist
  rescue
    puts 'Failed to connect to XMMS2 daemon.'  
  end 
  
  # returns status in xml
  def status_in_xml(message='')
    Builder::XmlMarkup.new(:indent => 2).response do |r|
      r.track_ttl(track_ttl)
      r.playlist do |p|
        list(9, 0).each_with_index do |entry, index|
          p.entry do |e|
            e.position(index)
            e.title(entry[:title])
            e.artist(entry[:artist])
            e.duration(duration_format(entry[:duration]))
            e.collection(collection_name(entry[:id]))
            e.url(entry[:url])
          end
        end
      end
      r.message(message)
    end
  end

  def track_ttl
    list(1, 0).first[:duration] - @xmms.playback_playtime.wait.value
  end

  # returns @string@, which is name of first collection found,
  # although generally there might be multiple collections
  def collection_name(id)
    ns = Xmms::Collection::NS_COLLECTIONS
    @xmms.coll_find(id, ns).wait.value.first
  end

  # skip current entry
  def skip
    @xmms.playlist_set_next_rel(1).wait
    @xmms.playback_tickle.wait
  end 
  
  # generate a idlist-collection from path, returns name
  def new_collection_from_path(path, name=nil)
    ns = Xmms::Collection::NS_COLLECTIONS
    import(path)
    name ||= path.split(File::SEPARATOR).last
    coll = Xmms::Collection.parse("url:*#{path}*")
    idlist = @xmms.coll_query_ids(coll).wait.value
    coll.idlist = idlist
    @xmms.coll_save(coll, name, ns).wait
    name
  end 
  
  # queue least often played randomly from collection
  # returns info hash for added entry
  def append_from_collection(name)
    if coll = collection(name)
      infos = info(coll.idlist)
      leasttimes = (infos.map { |i| i[:timesplayed] }).min
      candidates = infos.select { |i| i[:timesplayed] == leasttimes }
      random_entry = candidates[rand(candidates.size)]
      add(random_entry[:id])
      random_entry
    else
      puts "no collection named #{name}"
      false
    end
  end 
  
  # retrieve info for the next @limit@ entries in current playlist
  def list(limit=5, offset=1)
    pos = @playlist.current_pos.wait.value[:position]
    info(@playlist.entries.wait.value[pos + offset, limit])
  rescue
    # error if playlist empty
    return []
  end 

  # returns array of @info@ if playlist contains entries of collection denoted by @name@
  # returns @false@ otherwise
  def in_upcoming?(name)
    coll = collection(name)
    idlist = upcoming & coll.idlist
    idlist.empty? ? false : info(idlist)
  end
  
  # private
  
  # array of all upcoming ids in playlist
  def upcoming 
    pos = @playlist.current_pos.wait.value[:position]
    idlist = @playlist.entries.wait.value
    idlist[pos, idlist.size]
  rescue
    # error if playlist empty
    return []
  end

  # add path or id to current playist
  def add(path_or_id)
    @playlist.add_entry(path_or_id).wait.value
  end
  
  # import path recursively into medialib
  def import(path)
    puts "[DEBUG] importing from #{path.inspect}"
    @xmms.medialib_path_import('file://'+path).wait
  end 
  
  # get array of info hashes from medialib
  def info(idlist)
    rv = idlist.map { |id| @xmms.medialib_get_info(id).wait.value }
  end 
  
  # recursively add path to current playlist (we don't need that!)
  def radd(path)
    @playlist.radd(path).wait
  end
  
  # list playlists, which is kind of useless
  def playlists
    @xmms.coll_list(Xmms::Collection::NS_PLAYLISTS).wait.value
  end

  # list collections, which is not useless
  def collections
    @xmms.coll_list(Xmms::Collection::NS_COLLECTIONS).wait.value
  end
  
  # starts playback
  def play
    @xmms.playback_start.wait
  end

  # returns collection for given name out of namespace Xmms::Collection::NS_COLLECTIONS
  def collection(name)
    ns = Xmms::Collection::NS_COLLECTIONS
    @xmms.coll_get(name, ns).wait.value
  rescue
    puts "error finding collection named #{name.inspect} in namespace #{ns.inspect}"
    false
  end

  def purge
    @playlist.clear.wait
  end

  def current
    info([@xmms.playback_current_id.wait.value]).first
  end

end

# --------------------------------------------------------------------------------

if $0 == __FILE__
  xmms = XmmsAdapter.new
  case ARGV[0]
    when 'import'
    name = xmms.new_collection_from_path(ARGV[1])
    when 'append'
    xmms.append_from_collection(ARGV[1])
    when 'list'
    puts "Playlists: #{xmms.playlists.inspect}"
    puts "Collections: #{xmms.collections.inspect}"
    xmms.list.each { |e| puts "#{e[:artist]} - #{e[:title]} (#{e[:url]})" }
    when 'status'
    # we need to require builder for that
    puts xmms.status_in_xml('no message')
    when 'colls'
    puts xmms.collection_name(616)
    when 'ttl'
    puts xmms.track_ttl
  end
  xmms.play
end

