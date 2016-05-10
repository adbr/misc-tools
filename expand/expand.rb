#!/usr/bin/env ruby

# Description:: Zamienia tabulacje na spacje i odwrotnie.
# Author::      Adam Bryt
# Date::        2002-07-25
# License::     BSD, Copyright (c) 2001 Adam Bryt
# Version::     $Id$

# TODO - skrypt install.rb; manual
#
# Porownanie z innymi programami expand:
#
# * expand z NetBSD
#   - nie mozna rozwijac tylko poczatkowych znakow
#   - unexpand: nie mozna podac pozycji tabulatora
#
# * expand GNU
#   - unexpand: nie mozna rozwijac tylko poczatkowych spacji (bug?)

require "getoptlong"

class Tabulator

	attr_accessor :tabs

	def initialize(tabs=8)
		@tabs = tabs               # Integer or Array of Integers
	end

	def stop?(col)
		if @tabs.is_a? Integer
			(col % @tabs) == 0
		elsif @tabs.is_a? Array
			if col > @tabs.max
				true
			else
				@tabs.include?(col)
			end
		end
	end

end

class Expander

	attr_accessor :tabulator, :initial

	def initialize
		@tabulator = Tabulator.new
		@initial = false              # przetwarzaj tylko pocztkowe: "\t", "  "
	end

	def expand(str)
		new = ""
		str.each_line do |line|
			new << expand_line(line)
		end
		new
	end

	def unexpand(str)
		new = ""
		str.each_line do |line|
			new << unexpand_line(line)
		end
		new
	end

	private

	def expand_line(str)
		new = ""
		col = 0
		expand = true
		str.split("").each do |c|
			expand = false if @initial and expand and c =~ /\S/
			case c
			when "\t"
				if expand
					new << " "
					col += 1
					while ! @tabulator.stop?(col)
						new << " "
						col += 1
					end
				else
					new << c
					col += 1
				end
			when "\b"
				new << c
				col -= 1 if col > 0
			else
				new << c
				col += 1
			end
		end
		new
	end

	def unexpand_line(str)
		new = ""
		col = spc = 0
		unexpand = true
		str.split("").each do |c|
			unexpand = false if @initial and unexpand and c =~ /\S/
			case c
			when " "
				if unexpand
					spc += 1
					if @tabulator.stop?(col + spc)
						if spc == 1
							new << " "
						else
							new << "\t"
						end
						col = col + spc
						spc = 0
					end
				else
					new << c
					col += 1
				end
			when "\b"
				if spc > 0
					spc.times do new << " " end
					col = col + spc
					spc = 0
				end
				new << c
				col -= 1 if col > 0
			when "\t"
				spc = 0 if spc > 0
				new << c
				col += 1
				while ! @tabulator.stop?(col)
					col += 1
				end
			else
				if spc > 0
					spc.times do new << " " end
					col = col + spc
					spc = 0
				end
				new << c
				col += 1
			end
		end
		new
	end

end

class String

	class << self
		attr_accessor :tabulator
	end

	self.tabulator = Tabulator.new

	def expand(initial=false)
		exp = Expander.new
		exp.tabulator = String.tabulator
		exp.initial = initial
		exp.expand(self)
	end

	def unexpand(initial=false)
		exp = Expander.new
		exp.tabulator = String.tabulator
		exp.initial = initial
		exp.unexpand(self)
	end

end

class Options

	attr_accessor :initial, :unexpand, :tabs

	def initialize
		@initial = false
		@unexpand = false
		@tabs = 8                  # Integer or Array of Integers

		opts = GetoptLong.new
		opts.set_options(
			["-h", GetoptLong::NO_ARGUMENT],
			["-i", GetoptLong::NO_ARGUMENT],
			["-t", GetoptLong::REQUIRED_ARGUMENT],
			["-u", GetoptLong::NO_ARGUMENT]
		)
		begin
			opts.each do |opt, arg|
				case opt
				when "-h"
					help
					exit 0
				when "-i"
					@initial = true
				when "-u"
					@unexpand = true
				when "-t"
					a = arg.split(/\s*,\s*/).map do |i| Integer(i) end
					if a.size == 1
						@tabs = a[0]
					elsif a.size > 1
						@tabs = a
					else
						usage STDERR
						exit 1
					end
				end
			end
		rescue GetoptLong::InvalidOption
			usage STDERR
			exit 1
		end
	end

	def usage(io=STDERR)
		prog = File.basename($0)
		s = "usage: #{prog} [-hiu] [-t tabstop] [-t tab1,tab2,...,tabn] [file ...]"
		io.puts s
	end

	def help
		usage STDOUT
		s = <<-EOS
    -h help
    -i initial
    -u unexpand
		EOS
		puts s
	end

end

if __FILE__ == $0
	opt = Options.new
	exp = Expander.new
	exp.tabulator = Tabulator.new(opt.tabs)
	exp.initial = opt.initial

	process = proc do |line|
		if opt.unexpand
			exp.unexpand(line)
		else
			exp.expand(line)
		end
	end

	ARGF.each_line do |line|
		print process[line]
	end
end
