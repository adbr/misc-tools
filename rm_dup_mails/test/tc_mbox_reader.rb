# $Id$

$:.unshift ".."

require 'test/unit'
require 'rm_dup_mails'
require 'dane_testowe'

class TC_MboxReader_each_mail < Test::Unit::TestCase

  def test_each_mail_na_dupl_mbox
    ary = []

    open("DUPL.mbox") do |io|
      reader = MboxReader.new(io)
      reader.each_mail do |mail|
        ary << mail
      end
    end

    assert_equal DUPL_MBOX_ARY.size, ary.size
    assert_equal DUPL_MBOX_ARY, ary

    DUPL_MBOX_ARY.each_index do |i|
      assert_equal DUPL_MBOX_ARY[i], ary[i], "Indeks: #{i}"
    end
  end

  def test_each_mail_na_uniq_mbox
    ary = []

    open("UNIQ.mbox") do |io|
      reader = MboxReader.new(io)
      reader.each_mail do |mail|
        ary << mail
      end
    end

    assert_equal UNIQ_MBOX_ARY.size, ary.size
    assert_equal UNIQ_MBOX_ARY, ary

    UNIQ_MBOX_ARY.each_index do |i|
      assert_equal UNIQ_MBOX_ARY[i], ary[i], "Indeks: #{i}"
    end
  end

  def test_each_mail_na_pojedynczym_mailu
    ary = []

    open("A.mbox") do |io|
      reader = MboxReader.new(io)
      reader.each_mail do |mail|
        ary << mail
      end
    end

    assert_equal 1, ary.size
    assert_equal UNIQ_MBOX_ARY[0], ary[0]
  end

end

class TC_MboxReader_each_dup_id < Test::Unit::TestCase

  def test_each_dup_id
    ary = []

    open("DUPL.mbox") do |io|
      reader = MboxReader.new(io)
      reader.each_dup_id do |id|
        ary << id
      end
    end

    assert_equal 2, ary.size
    assert_equal DUP_IDS, ary
  end

  def test_each_dup_id_uniq_mbox
    ary = []

    open("UNIQ.mbox") do |io|
      reader = MboxReader.new(io)
      reader.each_dup_id do |id|
        ary << id
      end
    end

    assert_equal 0, ary.size
  end

end

class TC_MboxReader_each_uniq_mail < Test::Unit::TestCase

  def test_each_uniq_mail_na_dupl_mbox
    ary = []

    open("DUPL.mbox") do |io|
      reader = MboxReader.new(io)
      reader.each_uniq_mail do |mail|
        ary << mail
      end
    end

    assert_equal UNIQ_MBOX_ARY.size, ary.size
    assert_equal UNIQ_MBOX_ARY, ary

    UNIQ_MBOX_ARY.each_index do |i|
      assert_equal UNIQ_MBOX_ARY[i], ary[i], "Indeks: #{i}"
    end
  end

  def test_each_uniq_mail_na_uniq_mbox
    ary = []

    open("UNIQ.mbox") do |io|
      reader = MboxReader.new(io)
      reader.each_uniq_mail do |mail|
        ary << mail
      end
    end

    assert_equal UNIQ_MBOX_ARY.size, ary.size
    assert_equal UNIQ_MBOX_ARY, ary

    UNIQ_MBOX_ARY.each_index do |i|
      assert_equal UNIQ_MBOX_ARY[i], ary[i], "Indeks: #{i}"
    end
  end

  def test_each_uniq_mail_na_pojedynczym_mailu
    ary = []

    open("A.mbox") do |io|
      reader = MboxReader.new(io)
      reader.each_uniq_mail do |mail|
        ary << mail
      end
    end

    assert_equal 1, ary.size
    assert_equal UNIQ_MBOX_ARY[0], ary[0]
  end

end
