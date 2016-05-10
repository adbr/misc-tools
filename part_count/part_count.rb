#!/usr/bin/env ruby

# Name:: part_count.rb
# Description:: oblicza rozmiary partycji w sektorach
# Author:: Adam Bryt
# Date:: 2002-05-17
# Version:: $Id$

# Skrypt czyta z podanego pliku (lub stdin) opisy partycji i drukuje na stdout
# przeliczone parametry partycji, wyrazone w sektorach (1sektor == 512
# bajtow). Przykladowe dane wejsciowe:
#
#   a     63      100M
#   b     a       2G
#
# Karzdy wiersz zawiera dane o jednej partycji. Pola to kolejno: nazwa
# partycji, offset i rozmiar. Nazwa jest litera z zakresu a..z. Offset moze
# byc liczba lub nazwa partycji. Liczba oznacza offset w sektorach, natomiast
# litera oznacza offset bezposrednio za podana partycja. Rozmiar moze byc
# liczba (rozmiar w sektorach) lub liczba z przyrostkiem [KMGTPE] co oznacza
# rozmiar w bajtach (Kilo, Mega, ...). Na wyjsciu otrzymujemy liste parametrow
# partycji wyrazonych w sektorach.
#
# XXX zamienic kolejnosc: name offset size -> name size offset

class Partition

  attr_accessor :name, :offset, :size

  def to_s
    "#{@name}:\t#{@offset}\t#{size}"
  end

end

class PartCounter

  attr_reader :parts

  def initialize
    @parts = []
  end

  def add_part(name, offset, size)
    p = Partition.new
    p.name = prepare_name(name)
    p.offset = prepare_offset(offset)
    p.size = prepare_size(size)
    update_part(p)
  end

  def del_part(name)
    @parts.delete_if {|p| p.name == name}
  end

  private

  def prepare_name(name)
    if ("a".."z").to_a.include?(name.downcase)
      name.downcase
    else
      raise ArgumentError
    end
  end

  def prepare_offset(offset)
    if offset.kind_of?(Integer)
      return offset
    end
    if ! offset.instance_of?(String)
      raise ArgumentError
    end
    if ! ("a".."z").to_a.include?(offset.downcase)
      return offset.to_i
    end

    part = nil
    @parts.each do |p|
      if p.name == offset.downcase
        part = p
      end
    end
    if part
      sectors = part.offset + part.size
    else
      raise ArgumentError
    end
    sectors
  end

  def prepare_size(size)
    if size.kind_of?(Integer)
      return size
    end
    if ! size.instance_of?(String)
      raise ArgumentError
    end

    sectors = 0
    case size[-1..-1].upcase
    when "K"
      sectors = size[0...-1].to_i * 1024 / 512
    when "M"
      sectors = size[0...-1].to_i * 1048576 / 512
    when "G"
      sectors = size[0...-1].to_i * 1073741824 / 512
    when "T"
      sectors = size[0...-1].to_i * 1099511627776 / 512
    when "P"
      sectors = size[0...-1].to_i * 1125899906842624 / 512
    when "E"
      sectors = size[0...-1].to_i * 1152921504606846976 / 512
    else
      sectors = size.to_i
    end

    sectors
  end

  def update_part(part)
    exist = false
    @parts.each do |p|
      if p.name == part.name
        p.name = part.name
        p.offset = part.offset
        p.size = part.size
        exist = true
      end
    end
    if not exist
      @parts << part
    end
    @parts.sort! {|x, y| x.name <=> y.name}
  end

end

if __FILE__ == $0
  p = PartCounter.new
  ARGF.each_line do |line|
    a = line.split
    p.add_part(*a)
  end
  puts p.parts
end
