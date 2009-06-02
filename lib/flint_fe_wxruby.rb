#!/usr/bin/env ruby

require 'rubygems'
require 'wx'

require 'open-uri'
require 'xml_simple'

# returns xml
def call_flint(code='0')
  open("http://0.0.0.0:3000/options/execute_by_code/#{code}.xml").read
end

# ------------------------------------------------------------

class FlintPanel < Wx::Panel

  def initialize(parent)
    super(parent)
    evt_paint :on_paint
    #evt_timer 5000, :update
    evt_char :on_char
    @buffer = ''
    @data = nil
    update
  end

  def on_char(e)
    k = e.get_key_code
    if k==13
      update(@buffer)
      @buffer = ''
    else
      @buffer << k.chr
    end
    e.skip
  end

  def update(code='0')
    puts "sending code #{code}"
    @data = XmlSimple.xml_in(call_flint(code))
    refresh
  end

  def on_paint(evt)
    paint do |dc|
      if @data
        dc.set_background Wx::BLACK_BRUSH
        dc.set_brush Wx::GREEN_BRUSH
        dc.clear
        entries = @data['playlist'].first['entry'].sort_by { |e| e['position'] }
        y = 0
        entries.each_with_index do |e, i|
          pos = e['position'].first.to_i
          dc.draw_rectangle(100-12, 100-4, 400+24+24+2, 24) if pos==0
          dc.set_text_foreground(pos>0 ? Wx::GREEN : Wx::BLACK)
          info = e['artist'].first+' - '+e['title'].first
          dc.draw_text(info, 100, 100 + i * 24)
          dc.draw_text(e['duration'].first, 500, 100 + i * 24)
        end
        message = @data['message'].first
        dc.draw_text(message, 100, 500) unless message.empty?
      end
    end
  end

  #def animate
  #  refresh
  #end

end

# ------------------------------------------------------------

class FlintFrame < Wx::Frame

  def initialize
    wtitle = "FlintFE"
    #wpos   = Wx::DEFAULT_POSITION
    wpos   = Wx::Point.new(0, 0)
    #wsize  = Wx::Size.new(640, 480)
    wsize  = Wx::Size.new(1024, 768)
    #wstyle = Wx::DEFAULT_FRAME_STYLE # | Wx::WANTS_CHARS # Wx::BORDER_NONE
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

