#!/usr/bin/env ruby
#
# Filtr do konwersji z formatu The Vim Outliner do org-mode.
#
# $Id$

require 'optparse'

RE_HEADER = /^(\t*)([^\t]+)$/m
RE_TEXT = /^(\t*\|)(.*)$/m
RE_BLANK = /^\s+$/m
OPTIONS = {:maxlevel => nil}

def level(tabs)
  tabs.size + 1
end

def header_prefix(level)
  "*" * level
end

def validate_maxlevel(maxlevel)
  unless maxlevel.nil? || maxlevel.kind_of?(Integer)
    raise ArgumentError, "maxlevel is not Integer"
  end
  unless maxlevel.nil? || maxlevel >= 0
    raise ArgumentError, "maxlevel is <0"
  end
end

def otl2org(row, maxlevel=nil)
  validate_maxlevel(maxlevel)
  case row
  when RE_BLANK
    row
  when RE_TEXT  # musi byæ przed RE_HEADER
    $2
  when RE_HEADER
    tabs, header = $1, $2
    level = level(tabs)
    if (maxlevel.nil?) || (maxlevel >= level)
      header_prefix(level) + " " + header.lstrip
    else
      row
    end
  else
    row
  end
end

def parse_options
  opts = OptionParser.new
  opts.banner = "usage: #{File.basename($0)} [-h] [-n MAXLEVEL] [file...]"
  opts.on("-h", "--help") do
    puts opts
    exit
  end
  opts.on("-n MAXLEVEL", Integer) do |n|
    OPTIONS[:maxlevel] = n
  end
  opts.parse!
rescue OptionParser::ParseError => e
  puts e
  puts opts
  exit 1
end

if $0 == __FILE__
  parse_options
  ARGF.each do |row|
    print otl2org(row, OPTIONS[:maxlevel])
  end
end
