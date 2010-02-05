require 'rubygems'
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/test_data.rb'

#
# Test the operators (special characters, like & and |).
# (Other tests handle basic functionality and the methods inherited from
# the Enumerable mixin.)
#

module Tests

  class Test_BitStrings < Test::Unit::TestCase

    def test_000_EQUAL()
      #
      # Test == comparison of bitstrings.
      #
      TestVals.each do |sVal|
        #
        # Compare two identically-created unbounded bitstrings
        #
        bs1 = BitString.new(sVal)
        bs2 = BitString.new(sVal)
        assert(bs1 == bs2,
               "Test unbounded new('#{sVal}') == new('#{sVal}')")
        unless (sVal.gsub(/0/, '').empty?)
          bs2 = BitString.new(sVal + '0')
          assert(bs1 != bs2,
                 "Test unbounded new('#{sVal}') != new('#{sVal}0')")
        end
        #
        # Now against the string value.
        #
        assert(bs1 == sVal,
               "Test unbounded new('#{sVal}') == '#{sVal}'")
        unless (sVal.gsub(/0/, '').empty?)
          assert(bs1 != (sVal + '0'),
                 "Test unbounded new('#{sVal}') != '#{sVal}0'")
        end
        #
        # Now against the integer value.
        #
        assert(bs1 == sVal.to_i(2),
               "Test unbounded new('#{sVal}') == #{sVal.to_i(2)}")
        unless (sVal.gsub(/0/, '').empty?)
          assert(bs1 != (sVal.to_i(2) * 2),
                 "Test unbounded new('#{sVal}') != #{sVal.to_i(2) * 2}")
        end
        #
        # Now against the array representatione.
        #
        expected = sVal.split(//).collect { |val| val.to_i }
        assert(bs1 == expected,
               "Test unbounded new('#{sVal}') == #{expected.inspect}")
        unless (sVal.gsub(/0/, '').empty?)
          expected.push(0)
          assert(bs1 != expected,
                 "Test unbounded new('#{sVal}') != #{expected.inspect}")
        end
        #
        # Repeat for bounded bitstrings.
        #
        sVal_l = sVal.length
        bs1 = BitString.new(sVal, sVal_l)
        bs2 = BitString.new(sVal, sVal_l)
        assert(bs1 == bs2,
               "Test bounded new('#{sVal}') == new('#{sVal}')")
        bs2 = BitString.new(sVal + '0', sVal_l + 1)
        assert(bs1 != bs2,
               "Test bounded new('#{sVal}') != new('#{sVal}0')")
        #
        # Now against the string value.
        #
        assert(bs1 == sVal,
               "Test bounded new('#{sVal}') == '#{sVal}'")
        unless (sVal.gsub(/0/, '').empty?)
          assert(bs1 != (sVal + '0'),
                 "Test unbounded new('#{sVal}') != '#{sVal}0'")
        end
        #
        # Now against the integer value.
        #
        assert(bs1 == sVal.to_i(2),
               "Test unbounded new('#{sVal}') == #{sVal.to_i(2)}")
        unless (sVal.gsub(/0/, '').empty?)
          assert(bs1 != (sVal.to_i(2) * 2),
                 "Test unbounded new('#{sVal}') != #{sVal.to_i(2) * 2}")
        end
        #
        # Now against the array representatione.
        #
        expected = sVal.split(//).collect { |val| val.to_i }
        assert(bs1 == expected,
               "Test unbounded new('#{sVal}') == #{expected.inspect}")
        unless (sVal.gsub(/0/, '').empty?)
          expected.push(0)
          assert(bs1 != expected,
                 "Test unbounded new('#{sVal}') != #{expected.inspect}")
        end
      end
    end                         # def test_001_AND()

    def test_001_AND()
      #
      # Test ANDing with Array, String, BitString, and Integer values.
      #
      TestVals.each do |sVal|
        #
        # AND with two unbounded bitstrings
        #
        bs1 = BitString.new(sVal)
        bs2 = BitString.new(sVal)
        #
        # First test our assumption
        #
        assert_equal(bs2.to_i,
                     bs1.to_i,
                     "Verify bitstring.to_i values of two strings made " +
                     "from the same value are equal")
        #
        # Unbounded & unbounded
        #
        assert_equal(bs1.to_i,
                     (bs1 & bs2).to_i,
                     "Test unbounded '#{sVal}'1 & unbounded '#{sVal}'2 => " +
                     "'#{sVal}'")
        assert_equal(bs2.to_i,
                     (bs2 & bs1).to_i,
                     "Test unbounded '#{sVal}'2 & unbounded '#{sVal}'1 => " +
                     "'#{sVal}'")
        #
        # Unbounded & bounded
        #
        bs1 = BitString.new(sVal)
        bs2 = BitString.new(sVal, sVal.length)
        assert_equal(bs1.to_i,
                     (bs1 & bs2).to_i,
                     "Test unbounded '#{sVal}'1 & bounded '#{sVal}'2 => " +
                     "'#{sVal}'")
        assert_equal(bs2.to_i,
                     (bs2 & bs1).to_i,
                     "Test bounded '#{sVal}'2 & unbounded '#{sVal}'1 => " +
                     "'#{sVal}'")
        #
        # Bounded & unbounded
        #
        bs1 = BitString.new(sVal, sVal.length)
        bs2 = BitString.new(sVal)
        assert_equal(bs1.to_i,
                     (bs1 & bs2).to_i,
                     "Test bounded '#{sVal}'1 & unbounded '#{sVal}'2 => " +
                     "'#{sVal}'")
        assert_equal(bs2.to_i,
                     (bs2 & bs1).to_i,
                     "Test unbounded '#{sVal}'2 & bounded '#{sVal}'1 => " +
                     "'#{sVal}'")
        #
        # Bounded & bounded
        #
        bs1 = BitString.new(sVal, sVal.length)
        bs2 = BitString.new(sVal, sVal.length)
        assert_equal(bs1.to_i,
                     (bs1 & bs2).to_i,
                     "Test bounded '#{sVal}'1 & bounded '#{sVal}'2 => " +
                     "'#{sVal}'")
        assert_equal(bs2.to_i,
                     (bs2 & bs1).to_i,
                     "Test bounded '#{sVal}'2 & bounded '#{sVal}'1 => " +
                     "'#{sVal}'")
      end
    end                         # def test_001_AND()

    def test_002_LT()
      return unless (BitString.new.respond_to?(:<))
      assert(false, '###FAIL! .< not supported but .respond_to? is true!')
    end                         # def test_002_LT()

    def test_003_ShiftLeft()
      return unless (BitString.new.respond_to?(:<<))
      TestVals.each do |sVal|
        #
        # Start with unbounded strings.
        #
        rVal = sVal.to_i(2).to_s(2)
        bs = BitString.new(sVal)
        (sVal.length * 2).times do |i|
          expected = (rVal + '0' * i).to_i(2).to_s(2)
          assert_equal(expected,
                       (bs << i).to_s,
                       "Test unbounded '#{sVal}' << #{i} == #{expected}")
        end
        #
        # Now the bounded ones.
        #
        l = sVal.length
        bs = BitString.new(sVal, l)
        rVal = bs.to_s
        (sVal.length * 2).times do |i|
          expected = (rVal + '0' * i)[-l,l]
          assert_equal(expected,
                       (bs << i).to_s,
                       "Test bounded '#{sVal}' << #{i} == #{expected}")
        end
      end
    end                         # def test_003_ShiftLeft()

    def test_004_LEQ()
      return unless (BitString.new.respond_to?(:<=))
      assert(false, '###FAIL! .<= not supported but .respond_to? is true!')
    end                         # def test_004_LEQ()

    def test_005_GT()
      return unless (BitString.new.respond_to?(:>))
      assert(false, '###FAIL! .> not supported but .respond_to? is true!')
    end                         # def test_005_GT()

    def test_006_GEQ()
      return unless (BitString.new.respond_to?(:>=))
      assert(false, '###FAIL! .>= not supported but .respond_to? is true!')
    end                         # def test_006_GEQ()

    def test_007_ShiftRight()
      return unless (BitString.new.respond_to?(:>>))
      TestVals.each do |sVal|
        #
        # Start with unbounded strings.
        #
        rVal = sVal.to_i(2).to_s(2)
        bs = BitString.new(sVal)
        (sVal.length * 2).times do |i|
          expected = rVal[0,rVal.length-i]
          expected = '0' if (expected.nil? || expected.empty?)
          assert_equal(expected,
                       (bs >> i).to_s,
                       "Test unbounded '#{sVal}' >> #{i} == #{expected}")
        end
        #
        # Now the bounded ones.
        #
        l = sVal.length
        bs = BitString.new(sVal, l)
        rVal = bs.to_s
        (sVal.length * 2).times do |i|
          expected = ('0' * [i,l].min) + rVal[0,[rVal.length-i,0].max]
          assert_equal(expected,
                       (bs >> i).to_s,
                       "Test bounded '#{sVal}' >> #{i} == #{expected}")
        end
      end
    end                         # def test_007_ShiftRight()

    def test_008_XOR()
      return unless (BitString.new.respond_to?(:^))
      TestVals.each do |sVal|
        sVal_l = sVal.length
        #
        # Start with unbounded strings.
        #
        xbs = BitString.new(sVal)
        bs1 = xbs.dup
        ybs = BitString.new(rand(2**sVal_l))
        bs2 = ybs.dup
        bs1 = bs1 ^ bs2
        bs2 = bs1 ^ bs2
        bs1 = bs1 ^ bs2
        assert_equal(xbs.to_i,
                     bs2.to_i,
                     "Test unbounded A from A=A^B;B=A^B;A=A^B\n" +
                     "xbs=#{xbs.to_s}\n" +
                     "ybs=#{ybs.to_s}\n" +
                     "bs1=#{bs1.to_s}\n" +
                     "bs2=#{bs2.to_s}")
        assert_equal(ybs.to_i,
                     bs1.to_i,
                     "Test unbounded B from A=A^B;B=A^B;A=A^B\n" +
                     "xbs=#{xbs.to_s}\n" +
                     "ybs=#{ybs.to_s}\n" +
                     "bs1=#{bs1.to_s}\n" +
                     "bs2=#{bs2.to_s}")
        #
        # Now with bounded ones.
        #
        xbs = BitString.new(sVal, sVal_l)
        bs1 = xbs.dup
        ybs = BitString.new(rand(2**sVal_l), sVal_l)
        bs2 = ybs.dup
        bs1 = bs1 ^ bs2
        bs2 = bs1 ^ bs2
        bs1 = bs1 ^ bs2
        assert_equal(xbs.to_i,
                     bs2.to_i,
                     "Test bounded A from A=A^B;B=A^B;A=A^B\n" +
                     "xbs=#{xbs.to_s}\n" +
                     "ybs=#{ybs.to_s}\n" +
                     "bs1=#{bs1.to_s}\n" +
                     "bs2=#{bs2.to_s}")
        assert_equal(ybs.to_i,
                     bs1.to_i,
                     "Test bounded B from A=A^B;B=A^B;A=A^B\n" +
                     "xbs=#{xbs.to_s}\n" +
                     "ybs=#{ybs.to_s}\n" +
                     "bs1=#{bs1.to_s}\n" +
                     "bs2=#{bs2.to_s}")
        #
        # Now with bounded ones of different lengths.  Note that
        # XOR returns a bitstring the same length as its parent --
        # which means in the swap sequence below, both will end up
        # with the length of the shorter string.
        #
        xbs = BitString.new(sVal, sVal_l)
        bs1 = xbs.dup
        ybs = BitString.new(rand(2**(sVal_l * 2)), sVal_l * 2)
        bs2 = ybs.dup
        bs1 = bs1 ^ bs2
        bs2 = bs1 ^ bs2
        bs1 = bs1 ^ bs2
        new_l = [sVal_l, ybs.length].min
        assert_equal(xbs.resize(new_l).to_i,
                     bs2.resize(new_l).to_i,
                     "Test bounded A from A=A^B;B=A^B;A=A^B\n" +
                     "xbs=#{xbs.to_s}\n" +
                     "ybs=#{ybs.to_s}\n" +
                     "bs1=#{bs1.to_s}\n" +
                     "bs2=#{bs2.to_s}")
        assert_equal(ybs.resize(new_l).to_i,
                     bs1.resize(new_l).to_i,
                     "Test bounded B from A=A^B;B=A^B;A=A^B\n" +
                     "xbs=#{xbs.to_s}\n" +
                     "ybs=#{ybs.to_s}\n" +
                     "bs1=#{bs1.to_s}\n" +
                     "bs2=#{bs2.to_s}")
      end
    end                         # def test_008_XOR()

    def test_009_OR()
      return unless (BitString.new.respond_to?(:|))
      TestVals.each do |sVal|
        sVal_l = sVal.length
        #
        # Start with unbounded strings.
        #
        xbs = BitString.new(sVal)
        ybs = BitString.new(rand(2**sVal_l))
        expected = BitString.new(xbs.to_i | ybs.to_i)
        result = xbs | ybs
        assert_equal(expected,
                     result,
                     "Test unbounded X from X=A|B\n" +
                     "A  =#{xbs.to_s}\n" +
                     "B  =#{ybs.to_s}\n" +
                     "exp=#{expected.to_s}\n" +
                     "got=#{result.to_s}")
        result = ybs | xbs
        assert_equal(expected,
                     result,
                     "Test unbounded X from X=B|A\n" +
                     "A  =#{xbs.to_s}\n" +
                     "B  =#{ybs.to_s}\n" +
                     "exp=#{expected.to_s}\n" +
                     "got=#{result.to_s}")
        #
        # Now with bounded ones with the same lengths.
        #
        xbs = BitString.new(sVal, sVal_l)
        ybs = BitString.new(rand(2**sVal_l), sVal_l)
        expected = BitString.new(xbs.to_i | ybs.to_i, sVal_l)
        result = xbs | ybs
        assert_equal(expected,
                     result,
                     "Test bounded X from X=A|B\n" +
                     "A  =#{xbs.to_s}\n" +
                     "B  =#{ybs.to_s}\n" +
                     "exp=#{expected.to_s}\n" +
                     "got=#{result.to_s}")
        result = ybs | xbs
        assert_equal(expected,
                     result,
                     "Test bounded X from X=B|A\n" +
                     "A  =#{xbs.to_s}\n" +
                     "B  =#{ybs.to_s}\n" +
                     "exp=#{expected.to_s}\n" +
                     "got=#{result.to_s}")
        #
        # Now with bounded ones of different lengths.  Note that
        # OR returns a bitstring the same length as its parent --
        # which means in the swap sequence below, both will end up
        # with the length of the shorter string.
        #
        xbs = BitString.new(sVal, sVal_l)
        ybs = BitString.new(rand(2**(sVal_l * 2)), sVal_l * 2)
        expected = BitString.new((xbs.to_i | ybs.to_i) & xbs.mask, xbs.length)
        result = xbs | ybs
        assert_equal(expected,
                     result,
                     "Test bounded X from X=A|B (A.length != B.length)\n" +
                     "A  =#{xbs.to_s}\n" +
                     "B  =#{ybs.to_s}\n" +
                     "exp=#{expected.to_s}\n" +
                     "got=#{result.to_s}")
        expected = BitString.new((xbs.to_i | ybs.to_i) & ybs.mask, ybs.length)
        result = ybs | xbs
        assert_equal(expected,
                     result,
                     "Test bounded X from X=B|A (A.length != B.length)\n" +
                     "A  =#{xbs.to_s}\n" +
                     "B  =#{ybs.to_s}\n" +
                     "exp=#{expected.to_s}\n" +
                     "got=#{result.to_s}")
      end
    end                         # def test_009_OR()

    def test_010_NOT()
      return unless (BitString.new.respond_to?(:~))
      TestVals.each do |sVal|
        sVal_l = sVal.length
        #
        # Start with unbounded strings.
        #
        bs = BitString.new(sVal)
        expected = bs.mask
        result = (~ bs) | bs
        assert_equal(expected,
                     result,
                     "Test unbounded (~ '#{sVal}') | '#{sVal}' " +
                     "== '#{expected.to_s}'")
        #
        # Move on to bounded ones, which are a little more problematic.
        # Maybe.
        #
        bs = BitString.new(sVal, sVal_l)
        expected = BitString.new(bs.mask, sVal_l)
        result = (~ bs) | bs
        assert_equal(expected,
                     result,
                     "Test bounded (~ '#{sVal}') | '#{sVal}' " +
                     "== '#{expected.to_s}'")
        result = (~ bs) ^ bs
        assert_equal(expected,
                     result,
                     "Test bounded (~ '#{sVal}') ^ '#{sVal}' " +
                     "== '#{expected.to_s}'")
        expected = BitString.new(0, sVal_l)
        result = (~ bs) & bs
        assert_equal(expected,
                     result,
                     "Test bounded (~ '#{sVal}') & '#{sVal}' " +
                     "== '#{expected.to_s}'")
      end
    end                         # def test_010_NOT()

  end                           # class Test_BitStrings

end                             # module Tests
