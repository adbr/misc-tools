# $Id$

$: << ".."

require 'test/unit'
require 'rm_dup_mails'
require 'stringio'
require 'fileutils'
require 'timeout'

class TC_Utils < Test::Unit::TestCase

  DATA_TXT = "DATA.txt"

  def create_tmp_file(filename)
    File.open(filename, "w") do |ios|
      ios << "qwerty"
    end
  end

  def test_backup_file_tworzenie_pliku
    Utils.backup_file(DATA_TXT) do |backup|
      assert_equal true, DATA_TXT != backup
      assert_equal true, File.exist?(DATA_TXT)
      assert_equal true, File.exist?(backup)

      ino1 = File.stat(DATA_TXT).ino
      ino2 = File.stat(backup).ino
      assert_not_equal ino1, ino2

      s1 = File.read DATA_TXT
      s2 = File.read backup
      assert_equal s1, s2
    end
  end

  def test_backup_file_mode_taki_sam
    mode_sav = File.stat(DATA_TXT).mode

    File.chmod 0644, DATA_TXT

    Utils.backup_file(DATA_TXT) do |backup|
      m1 = File.stat(DATA_TXT).mode
      m2 = File.stat(backup).mode
      assert_equal m1, m2
    end

    mode = File.stat(DATA_TXT).mode
    File.chmod(0600, DATA_TXT)
    assert_not_equal mode, File.stat(DATA_TXT).mode

    Utils.backup_file(DATA_TXT) do |backup|
      m1 = File.stat(DATA_TXT).mode
      m2 = File.stat(backup).mode
      assert_equal m1, m2
    end

  ensure
    File.chmod(mode_sav, DATA_TXT)
  end

  def test_backup_file_usuwanie_backupu_na_koncu
    name = ""
    Utils.backup_file(DATA_TXT) do |backup|
      assert_equal true, File.exist?(backup)
      name = backup
    end
    assert_equal false, File.exist?(name)
  end

  def test_backup_file_plik_nie_istnieje
    assert_raises(RuntimeError) do
      Utils.backup_file("nie istnieje") do |backup|
      end
    end
  end

  def test_each_cli_filename
    result = %w[a b c]
    ary = []

    Utils.each_cli_filename(result) do |filename|
      ary << filename
    end

    assert_equal result, ary
  end

  def test_each_cli_filename_pusta_lista
    result = %w[]
    ary = []

    Utils.each_cli_filename(result) do |filename|
      ary << filename
    end

    assert_equal result, ary
  end

  def test_lock_file
    begin
      filename = "_tmp1.mbox"
      create_tmp_file(filename)

      Utils.lock_file(filename) do |f|
        assert_raises(TimeoutError) do
          timeout(2) do
            fork do
              Utils.lock_file(filename) do
                ;
              end
            end
            Process.waitall
          end
        end
      end

    ensure
      FileUtils.rm filename
    end
  end

  def test_otwarcie_pliku_do_czytania_i_zapisu
    begin
      filename = "_tmp.mbox"
      create_tmp_file(filename)

      File.open(filename, "r") do |ios_r|
        assert_equal "qwerty", ios_r.read

        File.open(filename, "w") do |ios_w|
          ios_r.rewind
          assert_equal "", ios_r.read

          ios_w << "asd"
          ios_w.flush

          ios_r.rewind
          assert_equal "asd", ios_r.read

          ios_w << "zxc"
        end

        ios_r.rewind
        assert_equal "asdzxc", ios_r.read
      end

    ensure
      FileUtils.rm filename
    end
  end

end
