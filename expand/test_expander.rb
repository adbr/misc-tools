require "test/unit"
require "expand"

class Test_expander < Test::Unit::TestCase

	def test_expand
		exp = Expander.new
		exp.tabulator = Tabulator.new(4)

		s = "\t\tabc\t\td\te"
		ok = "        abc     d   e"
		n = exp.expand(s)
		assert_equal ok, n

		exp.initial = true
		s = "\t\tabc\t\td\te"
		ok = "        abc\t\td\te"
		n = exp.expand(s)
		assert_equal ok, n

		exp.initial = false
		s = "\t\b\tabc\t\td\te"
		ok = "    \b abc     d   e"
		n = exp.expand(s)
		assert_equal ok, n

		## testy z uzyciem systemowego expand:

		exp.tabulator = Tabulator.new(8)

		s = "\tx\txx\txxx\txxxx\txxxxx\txxxxxx\txxxxxxx\txxxxxxxx\txxxxxxxxx"
		ok = `printf "#{s}" | expand`
		n = exp.expand(s)
		assert_equal ok, n

		s = "\tx\txx\txxx\txxxx\txxxxx\txxxx\nxx\txxxxxxx\txxx\nxxxxx\txxxxxxxxx"
		ok = `printf "#{s}" | expand`
		n = exp.expand(s)
		assert_equal ok, n

		s = "\t\tx\txx\t\t\txxx\txxxx\txxxxx\txxxxxx\txxxxxxx\txxxxxxxx\t"
		ok = `printf "#{s}" | expand`
		n = exp.expand(s)
		assert_equal ok, n

		s = "\b\b\t\tx\txx\t\b\b\t\txxx\tx\bxxx\txxxxx\txxxxxx\t"
		ok = `printf "#{s}" | expand`
		n = exp.expand(s)
		assert_equal ok, n

		s = "\t\t \t    \t\txxx\t       \t      \txxxxxx\txxxxxxx\txxxxxxxx\t"
		ok = `printf "#{s}" | expand`
		n = exp.expand(s)
		assert_equal ok, n

		exp.tabulator = Tabulator.new(2)

		s = "\t\tx\txx\t\t\txxx\txxxx\txxxxx\txxxxxx\txxxxxxx\txxxxxxxx\t"
		ok = `printf "#{s}" | expand -t2`
		n = exp.expand(s)
		assert_equal ok, n

		exp.tabulator = Tabulator.new([1, 2, 3])

		s = "\t\tx\txx\t\t\txxx\txxxx\txxxxx\txxxxxx\txxxxxxx\txxxxxxxx\t"
		ok = `printf "#{s}" | expand -t"1,2,3"`
		n = exp.expand(s)
		assert_equal ok, n
	end

	def test_unexpand
		exp = Expander.new
		exp.tabulator = Tabulator.new(4)

		s = "        x   x"
		ok = "\t\tx\tx" 
		n = exp.unexpand(s)
		assert_equal ok, n

		exp.initial = true
		s = "        x            x"
		ok = "\t\tx            x"
		n = exp.unexpand(s)
		assert_equal ok, n
		exp.initial = false

		## testy z uzyciem systemowego unexpand:

		exp.tabulator = Tabulator.new(8)

		s = "                x        xxx                  x"
		ok = `printf "#{s}" | gunexpand -a`
		n = exp.unexpand(s)
		assert_equal ok, n

		s = "               \n x        x\nxx                  x"
		ok = `printf "#{s}" | gunexpand -a`
		n = exp.unexpand(s)
		assert_equal ok, n

		s = "    \b\b       x  x\bx\bx            x"
		ok = `printf "#{s}" | gunexpand -a`
		n = exp.unexpand(s)
		assert_equal ok, n

		s = "\b\b  \b   x"
		ok = `printf "#{s}" | gunexpand -a`
		n = exp.unexpand(s)
		assert_equal ok, n

		s = "\t\t\b\b   \t           x \t       x\tx\bx        x"
		ok = `printf "#{s}" | gunexpand -a`
		n = exp.unexpand(s)
		# puts `printf "#{ok}" | cat -vte`
		# puts `printf "#{n}" | cat -vte`
		assert_equal ok, n
	end

end
