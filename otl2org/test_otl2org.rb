# $Id$

require 'test/unit'
require 'otl2org'

class Test_otl2org < Test::Unit::TestCase

  def test_header
    header_row_conversion = {
      "header poziomu 1" => "* header poziomu 1",
      "\theader poziomu 2" => "** header poziomu 2",
      "\t\theader poziomu 3\n" => "*** header poziomu 3\n",
      "\t\t header poziomu 3\n" => "*** header poziomu 3\n"
    }
    header_row_conversion.each do |otl, org|
      assert_equal(org, otl2org(otl))
    end
  end

  def test_header_przypadki_specjalne
    header_row_conversion = {
      "\t\t | text 3" => "*** | text 3",
      "" => "",
      " \n" => " \n",
      "\t\t  \n" => "\t\t  \n",
      "\n" => "\n"
    }
    header_row_conversion.each do |otl, org|
      assert_equal(org, otl2org(otl))
    end
  end

  def test_text
    text_row_conversion = {
      "| tekst 1" => " tekst 1",
      "\t| text 2\n" => " text 2\n",
      "\t\t|text 3" => "text 3"
    }
    text_row_conversion.each do |otl, org|
      assert_equal(org, otl2org(otl))
    end
  end

  def test_text_przypadki_specjalne
    text_row_conversion = {
      "\t|" => "",
      "\t|\n" => "\n",
      "\t|  \n" => "  \n",
      "|" => "",
      "|\n" => "\n",
      "|  \n" => "  \n"
    }
    text_row_conversion.each do |otl, org|
      assert_equal(org, otl2org(otl))
    end
  end

  def test_header_maxlevel
    maxlevel = nil
    header_row_conversion = {
      "header poziomu 1" => "* header poziomu 1",
      "\theader poziomu 2" => "** header poziomu 2",
      "\t\theader poziomu 3\n" => "*** header poziomu 3\n",
      "\t\t header poziomu 3\n" => "*** header poziomu 3\n"
    }
    header_row_conversion.each do |otl, org|
      assert_equal(org, otl2org(otl, maxlevel))
    end

    maxlevel = 0
    header_row_conversion = {
      "header poziomu 1" => "header poziomu 1",
      "\theader poziomu 2" => "\theader poziomu 2",
      "\t\theader poziomu 3\n" => "\t\theader poziomu 3\n",
      "\t\t header poziomu 3\n" => "\t\t header poziomu 3\n"
    }
    header_row_conversion.each do |otl, org|
      assert_equal(org, otl2org(otl, maxlevel))
    end

    maxlevel = 1
    header_row_conversion = {
      "header poziomu 1" => "* header poziomu 1",
      "\theader poziomu 2" => "\theader poziomu 2",
      "\t\theader poziomu 3\n" => "\t\theader poziomu 3\n",
      "\t\t header poziomu 3\n" => "\t\t header poziomu 3\n"
    }
    header_row_conversion.each do |otl, org|
      assert_equal(org, otl2org(otl, maxlevel))
    end

    maxlevel = 2
    header_row_conversion = {
      "header poziomu 1" => "* header poziomu 1",
      "\theader poziomu 2" => "** header poziomu 2",
      "\t\theader poziomu 3\n" => "\t\theader poziomu 3\n",
      "\t\t header poziomu 3\n" => "\t\t header poziomu 3\n"
    }
    header_row_conversion.each do |otl, org|
      assert_equal(org, otl2org(otl, maxlevel))
    end

    maxlevel = 3
    header_row_conversion = {
      "header poziomu 1" => "* header poziomu 1",
      "\theader poziomu 2" => "** header poziomu 2",
      "\t\theader poziomu 3\n" => "*** header poziomu 3\n",
      "\t\t\theader poziomu 4\n" => "\t\t\theader poziomu 4\n"
    }
    header_row_conversion.each do |otl, org|
      assert_equal(org, otl2org(otl, maxlevel))
    end

    maxlevel = -3
    header_row_conversion = {
      "header poziomu 1" => "* header poziomu 1",
      "\theader poziomu 2" => "** header poziomu 2",
      "\t\theader poziomu 3\n" => "*** header poziomu 3\n",
      "\t\t\theader poziomu 4\n" => "\t\t\theader poziomu 4\n"
    }
    header_row_conversion.each do |otl, org|
      assert_raise ArgumentError do
        otl2org(otl, maxlevel)
      end
    end

    maxlevel = 2.3
    header_row_conversion = {
      "header poziomu 1" => "* header poziomu 1",
      "\theader poziomu 2" => "** header poziomu 2",
      "\t\theader poziomu 3\n" => "*** header poziomu 3\n",
      "\t\t\theader poziomu 4\n" => "\t\t\theader poziomu 4\n"
    }
    header_row_conversion.each do |otl, org|
      assert_raise ArgumentError do
        otl2org(otl, maxlevel)
      end
    end
  end

end
