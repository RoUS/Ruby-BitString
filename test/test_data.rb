require 'rubygems'
require File.dirname(__FILE__) + '/test_helper.rb'

module Tests

  class Test_BitStrings < Test::Unit::TestCase

    TestVals = [
                '00000000000001111111111111',
                '00101001010100101010111001101101',
                '1100111000111100001111100000',
                '101100111000111100001111100000',
                '101010101010101010101010101010',
                '010101010101010101010101010101',
                '0000000000000000000000000000',
                '1111111111111111111111111111'
               ]

    IfNoneCalled = 'IfNone invoked'
    IfNone = lambda { return IfNoneCalled }

  end                         # class Test_BitStrings

end                           # module Tests
