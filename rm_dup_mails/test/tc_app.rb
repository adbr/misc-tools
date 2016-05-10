# $Id$

$: << ".."

require 'test/unit'
require 'stringio'
require 'rm_dup_mails'
require 'dane_testowe'

class TC_App < Test::Unit::TestCase

  def setup
    @app = App.new
  end

  def test_print_dup_ids_z_io
    dst = StringIO.new

    open("DUPL.mbox") do |src|
      @app.print_dup_ids(src, dst)
    end

    result = DUP_IDS.join("\n") << "\n"
    assert_equal result, dst.string
  end

  def test_print_dup_ids_z_filename
    out = StringIO.new

    @app.print_dup_ids("DUPL.mbox", out)

    result = DUP_IDS.join("\n") << "\n"
    assert_equal result, out.string
  end

  def test_print_dup_ids_z_io_bez_duplikatow
    dst = StringIO.new

    open("UNIQ.mbox") do |src|
      @app.print_dup_ids(src, dst)
    end

    result = ""
    assert_equal result, dst.string
  end

  def test_copy_uniq_mails
    src = StringIO.new
    src.string = File.read("DUPL.mbox")
    dst = StringIO.new

    @app.copy_uniq_mails(src, dst)

    result = File.read("UNIQ.mbox")
    assert_equal result, dst.string
  end

  def test_copy_uniq_mails_mbox_bez_duplikatow
    src = StringIO.new
    src.string = File.read("UNIQ.mbox")
    dst = StringIO.new

    @app.copy_uniq_mails(src, dst)

    result = File.read("UNIQ.mbox")
    assert_equal result, dst.string
  end

  def test_copy_uniq_mails_mbox_z_jednym_mailem
    src = StringIO.new
    src.string = File.read("A.mbox")
    dst = StringIO.new

    @app.copy_uniq_mails(src, dst)

    result = File.read("A.mbox")
    assert_equal result, dst.string
  end

  def test_remove_dup_mails
    begin
      filename = "_dupl.mbox"
      FileUtils.cp "DUPL.mbox", filename

      assert_not_equal "", `diff -u UNIQ.mbox #{filename}`
      @app.remove_dup_mails(filename)
      assert_equal "", `diff -u UNIQ.mbox #{filename}`
    ensure
      FileUtils.rm filename
    end
  end

  def test_remove_dup_mails_brak_duplikatow
    begin
      filename = "_dupl.mbox"
      FileUtils.cp "UNIQ.mbox", filename

      assert_equal "", `diff -u UNIQ.mbox #{filename}`
      @app.remove_dup_mails(filename)
      assert_equal "", `diff -u UNIQ.mbox #{filename}`
    ensure
      FileUtils.rm filename
    end
  end

  def test_remove_dup_mails_jeden_mail
    begin
      filename = "_dupl.mbox"
      FileUtils.cp "A.mbox", filename

      assert_equal "", `diff -u A.mbox #{filename}`
      @app.remove_dup_mails(filename)
      assert_equal "", `diff -u A.mbox #{filename}`
    ensure
      FileUtils.rm filename
    end
  end

end
