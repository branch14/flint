#!/usr/bin/env ruby

require 'rubygems'
require 'wx'

require 'open-uri'
require 'xmlsimple'

require 'uri'

# returns xml
def call_flint(code='0')
  # securely encode URI to skip on "strange" chars like '|()[]}...'
  code = URI.escape(code, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
  open("http://0.0.0.0:3000/options/execute_by_code/#{code}.xml").read
end

# ------------------------------------------------------------

class FlintPanel < Wx::Panel

  def initialize(parent)
    super(parent)
    evt_paint :on_paint
    evt_char :on_char
    @buffer = ''
    @data = nil
    _update
    set_focus
  end

  def on_char(e)
    k = e.get_key_code
    if k==13
      _update(@buffer) if @buffer.size > 0      # just hitting enter shouldn't trigger an update
      @buffer = ''
    elsif k==27 || k==8				# ESC and Backspace exit program
      exit 1
    else
      @buffer << k.chr if k < 127 && k > 33     # only take printable characters into account
    end
    e.skip
  end

  # rewrite file url to array consisting of [<last_directory_name>, <file_name>]
  def _rewrite(url)
     url = url.gsub("\+"," ")
     url.match('(.*)/([^/]*)/(.*)')
     [ $2, $3 ]
  end

  def _update(code='0')
    puts "sending code #{code}"
    @data = XmlSimple.xml_in(call_flint(code))
    refresh
  end

  def on_paint(evt)
    paint do |dc|
      if @data
        dc.set_background Wx::BLACK_BRUSH
        dc.clear
        dc.set_font(Wx::Font.new(20, Wx::FONTFAMILY_DECORATIVE, Wx::FONTSTYLE_NORMAL, Wx::FONTWEIGHT_NORMAL))
        dc.set_brush Wx::GREEN_BRUSH
        if entries = @data['playlist'].first['entry']
          entries = entries.sort_by { |e| e['position'] }
          y = 0
          entries.each_with_index do |e, i|
            pos = e['position'].first.to_i
            dc.draw_rectangle(0, 100-4, 1024, 40) if pos==0
            dc.set_text_foreground(pos>0 ? Wx::GREEN : Wx::BLACK)
	    # take url into account, if no id3 tag is given
	    if e['artist'].first.size==0
              data = [e['collection'].first] + _rewrite(e['url'].first)
	    else
              data = [e['collection'].first, e['artist'].first, e['title'].first]
	    end
            info = "%s: %s - %s" % data
            dc.draw_text(info, 40, 100 + i * 40)
            dc.draw_text(e['duration'].first, 1024-100, 100 + i * 40)
          end
          message = @data['message'].first
          unless message.empty?
            dc.set_brush Wx::GREEN_BRUSH
            dc.draw_rectangle(0, 500, 1024, 768 - 500 - 40)
            dc.set_text_foreground(Wx::BLACK)
            dc.draw_text(message, 40, 520) 
          end
        end
        if ttl = @data['track_ttl'].first.to_i
          unless @timer 
	    @timer = Wx::Timer.new(self)
            evt_timer(@timer.id) { _update }
	  end
          @timer.stop 
          @timer.start(ttl)
        end
      else
        dc.set_brush Wx::GREEN_BRUSH
        dc.draw_circle(1024 / 2, 768 /2, 300)
        dc.set_brush Wx::BLACK_BRUSH
        dc.draw_circle(1024 / 2, 768 /2, 260)
        dc.set_brush Wx::GREEN_BRUSH
        dc.draw_rectangle(1024 / 2 - 25, 768 / 2 - 25, 200, 50)
        dc.draw_rectangle(1024 / 2 - 25, 768 / 2 - 25, 50, -200)
      end
    end
  end

end

# ------------------------------------------------------------

class FlintFrame < Wx::Frame

  def initialize
    wtitle = "FlintFE"
    wpos   = Wx::Point.new(0, 0)
    wsize  = Wx::Size.new(1024, 768)
    wstyle = Wx::BORDER_NONE
    super(nil, -1, wtitle, wpos, wsize, wstyle)
    panel = FlintPanel.new(self)
  end

end

class FlintApp < Wx::App
  def on_init
    frame = FlintFrame.new
    frame.show(true)
  end
end

FlintApp.new.main_loop

