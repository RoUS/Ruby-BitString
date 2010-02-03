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
      assert(true)
    end                         # def test_007_ShiftRight()

    def test_008_XOR()
      return unless (BitString.new.respond_to?(:^))
      assert(true)
    end                         # def test_008_XOR()

    def test_009_OR()
      return unless (BitString.new.respond_to?(:|))
      assert(true)
    end                         # def test_009_OR()

    def test_010_NOT()
      return unless (BitString.new.respond_to?(:~))
      assert(true)
    end                         # def test_010_NOT()

  end                           # class Test_BitStrings

end                             # module Tests
