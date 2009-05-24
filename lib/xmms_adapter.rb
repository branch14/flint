#!/usr/bin/env ruby 

# apt-get install libxmmsclient-ruby
require 'xmmsclient'

class XmmsAdapter
  
  def initialize
    @xmms = Xmms::Client.new('sub0')
    @xmms.connect(ENV['XMMS_PATH'])
    @playlist = @xmms.playlist
  rescue
    puts 'Failed to connect to XMMS2 daemon.'  
  end 
  
  # skip current entry
  def skip
    @xmms.playback_tickle.wait
  end 
  
  # generate a idlist-collection from path, returns name
  def new_idlist_from_path(path, name=nil)
    ns = Xmms::Collection::NS_COLLECTIONS
    puts "[DEBUG] importing #{path.inspect}"
    import(path)
    name ||= path.split(File::SEPARATOR).last
    puts "[DEBUG] name will be #{name.inspect}"
    collection = Xmms::Collection.parse("url:*#{path}*")
    idlist = @xmms.coll_query_ids(collection).wait.value
    puts "[DEBUG] idlist is #{idlist.inspect}"
    collection.idlist = idlist
    @xmms.coll_save(collection, name, ns).wait
    puts "[DEBUG] idlist saved as #{name.inspect} in namepsace #{ns.inspect}"
    name
  end 
  
  # queue least often played randomly from collection
  def qloprfc(name)
    collection = @xmms.coll_get(name).wait
    p collection

    # info = info(collection.idlist)
    # leasttimes = (info.map { |i| i[:timesplayed] }).min
    # candidates = info.select { |i| leasttimes < i[:timesplayed] }
    # add(candidates[rand(candidates.size)][:id])
  end 
  
  # retrieve info for the next @limit@ entries in current playlist
  def list(limit=5)
    pos = @playlist.current_pos.wait.value[:position]
    info(@playlist.entries.wait.value[pos, limit])
  end 
  
  # private
  
  # add path or id to current playist
  def add(path_or_id)
    @playlist.add_entry(path_or_id).wait.value
  end
  
  # import path recursively into medialib
  def import(path)
    @xmms.medialib_path_import('file://'+path).wait
  end 
  
  # get array of info hashes from medialib
  def info(idlist)
    idlist.map { |id| @xmms.medialib_get_info(id).wait.value }
  end 
  
  # recursively add path to current playlist (we don't need that!)
  def radd(path)
    @playlist.radd(path).wait
  end
  
  def playlists
    @xmms.coll_list(Xmms::Collection::NS_PLAYLISTS).wait.value
  end

  def collections
    @xmms.coll_list(Xmms::Collection::NS_COLLECTIONS).wait.value
  end
  
  def play
    @xmms.playback_start.wait
  end

end

# --------------------------------------------------------------------------------

if $0 == __FILE__
  xmms = XmmsAdapter.new
  xmms.play
  # p xmms.add('/media/My Passport/musik/1999 - v Muslimgauze/Bass Communion v Muslimgauze - 01 - One.mp3')
  # p xmms.skip
  # r = xmms.list5
  # p r.first
  # r.each { |e| puts "#{e[:artist]} - #{e[:title]} (#{e[:url]})" }
  name = xmms.new_idlist_from_path('/home/phil/mp3/niffpage.greywool.com/files/Music/Enskog')
  xmms.qloprfc(name)
  xmms.list.each { |e| puts "#{e[:artist]} - #{e[:title]} (#{e[:url]})" }
  # p xmms.import('/home/phil/mp3/niffpage.greywool.com/files/Music/Winterscapes')
  # p xmms.playlists
  # p xmms.collections
end

