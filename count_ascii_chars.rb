#!/usr/bin/env ruby


STDIN.each do |ln|
  ln.rstrip!
  ascii_char_count = ln.chars.to_a.select{|c| c.ascii_only?}.length
  print "#{ascii_char_count}\t#{ln}\n"
end

# END
