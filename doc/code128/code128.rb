#/usr/bin/env ruby

require 'erb'

command = ARGV[0]

def code128(code)
   ['moveto', "(^105#{code})", "(includetext height=0.4)", 'code128']
end

case command.to_sym

when :cheque
  code = ARGV[1]
  page_width = 240.944882 
  page_height = 153.070866
  barcode_x = 90
  barcode_y = 20
  content = [barcode_x, barcode_y, code128(code)].flatten*' '

when :labels
  filename = ARGV[1]
  columns = 3
  rows = 8
  paper_width = 595.275591 # 21 cm
  paper_height = 841.889764 # 29,7 cm
  barcode_x = 70
  barcode_y = 20
  text_x = 30
  text_y = 45
  label_width = 198.425197 # 70 mm # paper_width.to_f / columns
  label_height = 102.047244 # 36 mm # paper_height.to_f / rows
  paper_offset_y = 12.5574803 - 42.519685 + label_height
  content = []
  codes = File.read(filename).split("\n").map { |c| c.split(':') }
  counter = 0
  codes.each do |code|
    x = (counter % columns) * label_width
    y = (counter / columns) * label_height + paper_offset_y
    content << [x + barcode_x, y + barcode_y, code128(code.first)].flatten*' '
    content << [x + text_x, y + text_y, 'moveto', "(#{code.last})", 'show']*' '
    counter = counter + 1
  end
  content = content.join("\n")

when :veto
  offset = (ARGV[1] || 666000).to_i 
  columns = 4
  rows = 8
  paper_width = 595.275591 # 21 cm
  paper_height = 841.889764 # 29,7 cm
  barcode_x = 40
  barcode_y = 20
  text_x = 40
  text_y = 40
  label_width = paper_width.to_f / columns
  label_height = paper_height.to_f / rows
  content = []
  (columns * rows).times do |counter|
    x = (counter % columns) * label_width
    y = (counter / columns) * label_height
    content << [x + barcode_x, y + barcode_y, code128((offset + counter).to_s)].flatten*' '
    content << [x + text_x, y + text_y, 'moveto', "(Veto)", 'show']*' '
  end
  content = content.join("\n")

end

template_file = 'code128.ps.erb'
tmpl = File.read(template_file)
postscript = ERB.new(tmpl).result
# File.open("#{code}.ps", 'w') { |f| f.write(postscript) }
puts postscript
