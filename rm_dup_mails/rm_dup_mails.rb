#! /usr/bin/env ruby
# $Id$
# Usuwanie duplikatow maili z mailboxow w formacie mbox.

require 'rmail'
require 'optparse'
require 'fileutils'

class Seq

  @current = 0

  class << self
    
    attr_accessor :current

    def next
      @current += 1
    end

  end

end

class MboxReader

  def initialize(ios)
    @ios = ios
  end

  def each_mail(&block)
    RMail::Mailbox.parse_mbox(@ios) do |str|
      block.call(str)
    end
  end

  def each_dup_id(&block)
    idhash = Hash.new(0)

    each_mail do |str|
      id = message_id(str)
      idhash[id] += 1
    end

    idhash.each do |k, v|
      block.call(k) if v > 1
    end
  end

  def each_uniq_mail(&block)
    idhash = Hash.new(0)

    each_mail do |str|
      id = message_id(str)
      idhash[id] += 1
      block.call(str) if idhash[id] == 1
    end
  end

  def message_id(str)
    mail = RMail::Parser.read(str)
    mail.header.message_id.dup
  end

end

class MboxWriter

  def initialize(ios)
    @ios = ios
    @empty = (ios.pos == 0)
  end

  def write(mailstr)
    @ios << "\n" if not @empty
    @ios << mailstr
    @empty = false
  end

end

module Utils

  def each_cli_filename(ary=ARGV, &block)
    ary.each do |filename|
      block.call filename
    end
  end

  def backup_file(filename, &block)
    raise "Plik: #{filename} nie istnieje" if !File.exist?(filename)

    backup = filename + ".#{$$}.#{Seq.next}.bak"
    raise "Plik: #{backup} juz istnieje" if File.exist?(backup)

    FileUtils.cp(filename, backup, :preserve => true)
    block.call(backup)
    File.delete(backup)
  end

  def lock_file(filename, &block)
    begin
      f = File.open(filename, "r")
      f.flock File::LOCK_EX
      block.call(f)
    ensure
      f.flock File::LOCK_UN
      f.close
    end
  end

  def check_filename(filename)
    raise "Plik #{filename} nie istnieje" if !File.exist?(filename)
  end

  module_function :each_cli_filename, :backup_file, :lock_file,
                  :check_filename

end

class App

  include Utils

  def version
    "0.0.1"
  end

  def program_name
    File.basename($0)
  end

  def usage
    "usage: #{program_name} [-huvn] [FILENAME ...] | -b FILENAME ..."
  end

  def help
    str = <<-EOS
    I#{program_name} - usuwa duplikaty maili z mailboxow w formacie mbox
    I#{usage.chomp}
    I    -h  help
    I    -u  usage
    I    -v  version
    I    -n  nie usuwa duplikatow tylko drukuje ich Message-ID na stdout
    I    -b  batch
    I
    IPrzyklady:
    I    Bez opcji -b dziala jak zwykly filtr.
    I    Z opcja -b modyfikuje pliki o nazwach podanych jako argumenty.
    I
    I    ruby rm_dup_mails.rb mbox_file
    I        drukuje na stdout zawartosc mbox_file po usunieciu duplikatow
    I    ruby rm_dup_mails.rb -n mbox_file
    I        drukuje na stdout message_id duplikatow z mbox_file
    I    ruby rm_dup_mails.rb -b mbox_file
    I        usuwa duplikaty w pliku mbox_file (modyfikuje plik)
    I    ruby rm_dup_mails.rb -bn mbox_file
    I        drukuje na stdout message_id duplikatow z mbox_file
    EOS
    str.gsub(/^\s+I/, "")
  end

  def parse_options
    options = {}
    parser = OptionParser.new

    parser.on("-h") do
      puts help
      exit 0
    end

    parser.on("-u") do
      puts usage
      exit 0
    end

    parser.on("-v") do
      puts "#{program_name}: version: #{version}"
      exit 0
    end

    parser.on("-n") do |o|
      options[:nomodify] = o
    end

    parser.on("-b") do |o|
      options[:batch] = o
    end

    begin
      parser.parse!
      if options[:batch] and ARGV.size == 0
        puts usage
        exit 1
      end
    rescue => e
      warn "#{program_name}: #{e}"
      warn usage
      exit 1
    end

    options
  end

  def copy_uniq_mails(srcios, dstios)
    reader = MboxReader.new(srcios)
    writer = MboxWriter.new(dstios)
    reader.each_uniq_mail do |mail|
      writer.write mail
    end
  end

  def print_dup_ids_io(mboxios, dstios)
    reader = MboxReader.new(mboxios)
    reader.each_dup_id do |id|
      dstios << id << "\n"
    end
  end

  def print_dup_ids(src, outios=STDOUT)
    if src.is_a?(String)
      File.open(src) do |io|
        print_dup_ids_io(io, outios)
      end
    else
        print_dup_ids_io(src, outios)
    end
  end

  def remove_dup_mails(filename)
    lock_file(filename) do
      backup_file(filename) do |backup|
        open(backup, "r") do |src|
          open(filename, "w") do |dst|
            copy_uniq_mails(src, dst)
          end
        end
      end
    end
  end

  def batch(nomodify)
    if nomodify
      each_cli_filename do |filename|
        check_filename(filename)
        print_dup_ids(filename)
      end
      return
    end

    each_cli_filename do |filename|
      check_filename(filename)
      remove_dup_mails(filename)
    end
  end

  def filter(nomodify)
    if nomodify
      print_dup_ids(ARGF)
      return
    end

    copy_uniq_mails(ARGF, STDOUT)
  end

  def main
    options = parse_options

    if options[:batch]
      batch(options[:nomodify])
      exit 0
    end

    filter(options[:nomodify])
    exit 0
  end

end

if $0 == __FILE__
  App.new.main
end
