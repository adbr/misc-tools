#! /usr/bin/env ruby
#
# $Id$

# Skrypt dostaje na wej¶cie ci±g wierszy i drukuje je na stdout
# w losowej kolejno¶ci.
#
# przyk³adowe zastosowanie: odtwarzanie plików z muzyk± w losowej kolejno¶ci
#   find cds -type f | randomize.rb | xargs mplayer

def progname
  File.basename $0
end

def usage
  STDERR.puts "usage: #{progname} [-w] [-n num] [file ...]"
  exit 1
end

def help
  puts <<EOS
usage: #{progname} [-w] [-n num] [file ...]
  Czyta z plików o nazwach podanych przy wywo³aniu lub z stdin
  ci±g wierszy i drukuje je na stdout w kolejno¶ci losowej

  -w -- dzieli wej¶cie na s³owa zamiast na wiersze
  -n num -- drukuje maksymalnie num stringów
EOS
  exit 0
end

def parse_options
  require 'optparse'
  opt = {}

  op = OptionParser.new
  op.on("-w") {opt[:words] = true}
  op.on("-n num", Integer) {|n| opt[:number] = n.abs}
  op.on("-h") {help}
  op.parse!

  return opt
rescue OptionParser::ParseError => e
  STDERR.puts e
  usage
end

def shuffle(ary)
  ary.size.times do
    a = rand(ary.size)
    b = rand(ary.size)
    ary[a], ary[b] = ary[b], ary[a]
  end
  ary
end

def read
  ary = []
  ARGF.each do |row|
    if OPT[:words]
      ary = ary.concat(row.split)
    else
      ary << row
    end
  end
  ary
end

OPT = parse_options
ary = read
ary = shuffle(ary)

if OPT[:number]
  puts ary[0, OPT[:number]]
else
  puts ary
end
