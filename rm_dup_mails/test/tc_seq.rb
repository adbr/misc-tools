# $Id$

$:.unshift ".."

require 'test/unit'
require 'rm_dup_mails'

class TC_Seq < Test::Unit::TestCase

  def test_seq
    n = Seq.current
    Seq.current = 0

    assert_equal 0, Seq.current
    assert_equal 0, Seq.current

    assert_equal 1, Seq.next
    assert_equal 2, Seq.next
    assert_equal 3, Seq.next

    assert_equal 3, Seq.current

    Seq.current = n
  end

end
