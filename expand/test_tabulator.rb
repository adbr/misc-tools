require "test/unit"
require "expand"

class Test_Tabulator < Test::Unit::TestCase

	def test_initialize
		tab = Tabulator.new
		assert_equal false, tab.stop?(-1)
		assert_equal true, tab.stop? 0
		assert_equal false, tab.stop? 1
		assert_equal true,  tab.stop? 8
		assert_equal false, tab.stop? 15
		assert_equal true, tab.stop? 16
	end

	def test_initialize_step
		tab = Tabulator.new(2)
		assert_equal false, tab.stop?(-1)
		assert_equal true, tab.stop? 0
		assert_equal false, tab.stop? 1
		assert_equal true,  tab.stop? 2
		assert_equal false, tab.stop? 15
		assert_equal true, tab.stop? 16
	end

	def test_initialize_array
		tab = Tabulator.new [0, 3, 5, 6, 12]
		assert_equal false, tab.stop?(-1)
		assert_equal true, tab.stop? 0
		assert_equal false, tab.stop? 1
		assert_equal false,  tab.stop? 2
		assert_equal true, tab.stop? 3
		assert_equal true, tab.stop? 5
		assert_equal true, tab.stop? 6
		assert_equal true, tab.stop? 12
		assert_equal true, tab.stop? 15
	end

end
