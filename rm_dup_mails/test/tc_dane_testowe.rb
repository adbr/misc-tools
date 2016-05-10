# $Id$

require 'test/unit'
require 'dane_testowe'

class TC_dane_testowe < Test::Unit::TestCase

  def test_0
    assert DUPL_MBOX_STR.size > 0
    assert UNIQ_MBOX_STR.size > 0

    assert_equal 7, DUPL_MBOX_ARY.size
    assert_equal 4, UNIQ_MBOX_ARY.size

    assert_equal DUPL_MBOX_ARY[0], UNIQ_MBOX_ARY[0]
    assert_equal DUPL_MBOX_ARY[1], UNIQ_MBOX_ARY[1]
    assert_equal DUPL_MBOX_ARY[2], UNIQ_MBOX_ARY[2]
    assert_equal DUPL_MBOX_ARY[3], UNIQ_MBOX_ARY[3]

    assert_equal DUPL_MBOX_ARY[0], DUPL_MBOX_ARY[5]
    assert_equal DUPL_MBOX_ARY[0], DUPL_MBOX_ARY[6]

    assert_equal DUPL_MBOX_ARY[3], DUPL_MBOX_ARY[4]
  end

end
