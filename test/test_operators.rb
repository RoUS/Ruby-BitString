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
    end                         # def test_001_AND()

    def test_002_LT()
    end                         # def test_002_LT()

    def test_003_ShiftLeft()
    end                         # def test_003_ShiftLeft()

    def test_004_LEQ()
    end                         # def test_004_LEQ()

    def test_005_GT()
    end                         # def test_005_GT()

    def test_006_GEQ()
    end                         # def test_006_GEQ()

    def test_007_ShiftRight()
    end                         # def test_007_ShiftRight()

    def test_008_XOR()
    end                         # def test_008_XOR()

    def test_009_OR()
    end                         # def test_009_OR()

    def test_010_NOT()
    end                         # def test_010_NOT()

  end                           # class Test_BitStrings

end                             # module Tests
