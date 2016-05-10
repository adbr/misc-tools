# $Id$

$:.unshift ".."

require 'test/unit'
require 'rm_dup_mails'
require 'dane_testowe'

class TC_MboxWriter < Test::Unit::TestCase

  # XXX lock

  def test_write
    open("new.mbox", "w") do |io|
      writer = MboxWriter.new(io)
      DUPL_MBOX_ARY.each do |mail|
        writer.write(mail)
      end
    end

    str = `diff DUPL.mbox new.mbox`
    assert_equal "", str

    File.unlink "new.mbox"
  end

  def test_write_do_istniejacego_mailboxu
    open("new.mbox", "w") do |io|
      writer = MboxWriter.new(io)
      writer.write UNIQ_MBOX_ARY[0]
      writer.write UNIQ_MBOX_ARY[1]
      writer.write UNIQ_MBOX_ARY[2]
    end

    open("new.mbox", "a") do |io|
      writer = MboxWriter.new(io)
      writer.write UNIQ_MBOX_ARY[3]
    end

    str = `diff -u UNIQ.mbox new.mbox`
    assert_equal "", str

    File.delete "new.mbox"
  end

  def test_write_jeden_mail
    open("new.mbox", "w") do |io|
      writer = MboxWriter.new(io)
      writer.write UNIQ_MBOX_ARY[0]
    end

    str = `diff -u A.mbox new.mbox`
    assert_equal "", str

    File.delete "new.mbox"
  end

end
