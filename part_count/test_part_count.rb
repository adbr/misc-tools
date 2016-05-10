# Name:: tc_part_count.rb
# Description:: test case dla part_count.rb
# Author:: Adam Bryt
# Date:: 2002-05-17
# Version:: $Id$

require "test/unit"
require "part_count"

class Test_PartCounter < Test::Unit::TestCase

  def test_initialize
    p = PartCounter.new
    assert_equal([], p.parts)
  end

  def test_all
    puts
    pc = PartCounter.new
    pc.add_part("a", "63", "100M")
    puts pc.parts; puts
    assert_equal("a", pc.parts[0].name)
    assert_equal(63, pc.parts[0].offset)
    assert_equal(204800, pc.parts[0].size)

    pc.add_part("b", "a", "2G")
    puts pc.parts; puts
    assert_equal("b", pc.parts[1].name)
    assert_equal(204863, pc.parts[1].offset)
    assert_equal(4194304, pc.parts[1].size)

    pc.add_part("c", "b", "5000")
    puts pc.parts; puts
    assert_equal("c", pc.parts[2].name)
    assert_equal(4399167, pc.parts[2].offset)
    assert_equal(5000, pc.parts[2].size)

    pc.del_part "b"
    assert_equal(2, pc.parts.size)
    puts pc.parts; puts

    pc.add_part("b", "a", "2G")
    puts pc.parts; puts
    assert_equal("b", pc.parts[1].name)
    assert_equal(204863, pc.parts[1].offset)
    assert_equal(4194304, pc.parts[1].size)
  end

end
