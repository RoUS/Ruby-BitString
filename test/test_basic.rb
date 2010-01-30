require 'rubygems'
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/test_data.rb'

#
# Test basic functionality, and non-operator methods we provide.
# (Other tests handle operators and the methods inherited from
# the Enumerable mixin.)
#

module Tests

  class Test_BitStrings < Test::Unit::TestCase

    #
    # Just test creating the objects.  We'll test whether they're valid
    # later.
    #
    def test_000_construction()
      TestVals.each do |sVal|
        lVal = sVal.length
        #
        # Turn the binary string into an integer.
        #
        iVal = sVal.to_i(2)
        #
        # Reverse the string.
        #
        sVal_r = sVal.reverse
        #
        # Make an array of the digits as strings, and one of the digits as
        # integers.
        #
        iVal_a = (sVal_a = sVal.split(//)).map { |bit| bit.to_i }
        #
        # Make reversed copies of those, too.
        #
        sVal_a_r = sVal_a.reverse
        iVal_a_r = iVal_a.reverse

        #
        # Test making an unbounded string from the integer.
        #
        assert_nothing_raised do
          bs = BitString.new(iVal)
        end

        #
        # From the string.
        #
        assert_nothing_raised do
          bs = BitString.new(sVal)
        end

        #
        # From the array of integers.
        #
        assert_nothing_raised do
          bs = BitString.new(iVal_a)
        end

        #
        # Try bounded now.
        #
        assert_nothing_raised do
          bs = BitString.new(iVal, lVal)
        end
        assert_nothing_raised do
          bs = BitString.new(sVal, lVal)
        end
        assert_nothing_raised do
          bs = BitString.new(iVal_a, lVal)
        end

        #
        # Again, with lengths shorter than the values.
        #
        assert_nothing_raised do
          bs = BitString.new(iVal, lVal / 2)
        end
        assert_nothing_raised do
          bs = BitString.new(sVal, lVal / 2)
        end
        assert_nothing_raised do
          bs = BitString.new(iVal_a, lVal / 2)
        end

        #
        # Now the block (bounded) form.
        #
        assert_nothing_raised do
          bs = BitString.new(lVal) { |bit| sVal_a_r[bit] }
        end
        assert_nothing_raised do
          bs = BitString.new(lVal) { |bit| iVal_a_r[bit] }
        end

        #
        # Check that the constructor arguments are vetted.
        #
        assert_raise(ArgumentError) do
          bs = BitString.new('a')
        end
        assert_raise(ArgumentError) do
          bs = BitString.new(iVal_a.collect { |v| v * 2 })
        end
        tVal = iVal.to_s
        assert_raise(ArgumentError) do
          bs = BitString.new(tVal)
        end
        assert_raise(ArgumentError) do
          bs = BitString.new(tVal, tVal.length)
        end
        assert_raise(ArgumentError) do
          bs = BitString.new('a', 1)
        end
        assert_raise(ArgumentError) do
          bs = BitString.new(0, 'a')
        end
      end
    end

    #
    # Test that conversion to an integer value works properly, since
    # we depend on the to_i() method later in the tests.
    #
    def test_001_to_i()
      TestVals.each do |sVal|
        iVal = sVal.to_i(2)
        bs = BitString.new(sVal)
        assert_equal(iVal,
                     bs.to_i,
                     "Test BitString.to_i(#{sVal}) => #{iVal}")
      end
    end

    #
    # Test that conversion *from* an integer value works properly.
    #
    def test_002_from_i()
      TestVals.each do |sVal|
        iVal = sVal.to_i(2)
        bs = BitString.new(0)
        bs.from_i(iVal)
        assert_equal(iVal,
                     bs.to_i,
                     "Test BitString.from_i(#{sVal}) => #{iVal}")
      end
    end

    #
    # Similarly, consider the to_s() method very early because we depend
    # on it later.
    #
    def test_003_to_s()
      TestVals.each do |sVal|
        iVal = sVal.to_i(2)
        sVal_e = sVal.sub(/^0+/, '')
        bs = BitString.new(sVal)
        assert_equal(sVal_e,
                     bs.to_s,
                     "Test unbounded '#{sVal}'.to_s => '#{sVal_e}'")
        bs = BitString.new(sVal, sVal.length)
        assert_equal(sVal,
                     bs.to_s,
                     "Test bounded '#{sVal}'.to_s => '#{sVal}'")
      end
    end

    #
    # The length() method is pretty important, too.
    #
    def test_004_length()
      TestVals.each do |sVal|
        #
        # The length() method returns either the size of a bounded
        # bitstring, or the number of digits from the most significant
        # 1.
        #
        uLength  = sVal.sub(/^0+/, '').length
        bLength = sVal.length
        bs = BitString.new(sVal)
        assert_equal(uLength,
                     bs.length,
                     "Test unbounded '#{sVal}'.length => #{uLength}")
        #
        # Now do the same check for the bounded version.
        #
        bs = BitString.new(sVal, sVal.length)
        bLength = sVal.length
        assert_equal(bLength,
                     bs.length,
                     "Test bounded '#{sVal}'.length => #{bLength}")
      end
    end

    #
    # Test that string are being properly marked as bounded -- or not.
    #
    def test_005_bounded?()
      TestVals.each do |sVal|
        bs = BitString.new(sVal)
        assert(! bs.bounded?)
        bs = BitString.new(sVal, sVal.length)
        assert(bs.bounded?)
        bs = BitString.new(sVal.length) { |i| sVal.reverse[i,1].to_i }
        assert(bs.bounded?)
      end
    end

    #
    # Test the clear() and clear!() methods.
    #
    def test_006_clear()
      TestVals.each do |sVal|
        bs = BitString.new(sVal)
        tbs = bs.clear
        assert_equal(sVal.to_i(2),
                     bs.to_i,
                     "Test that '#{sVal}'.clear() leaves original set")
        assert_equal(0,
                     tbs.to_i,
                     "Test that '#{sVal}'.clear() returns cleared bitstring")
        bs.clear!
        assert_equal(0,
                     bs.to_i,
                     "Test that '#{sVal}'.clear!() clears original bitstring")
      end
    end                         # def test_006_clear()

    #
    # Indexed access is critically important, so we test its permutations
    # here rather in the 'operators' test set.
    #

    #
    # Try simple single-bit accesses through the [] method.
    #
    def test_007_indexing()
      TestVals.each do |sVal|
        lVal = sVal.length
        iVal_a_r = sVal.reverse.split(//).map { |bit| bit.to_i }
        bs = BitString.new(sVal)
        #
        # Let's try fetching each bit.
        #
        lVal.times do |i|
          assert_equal(iVal_a_r[i],
                       bs[i],
                       "Test fetching index [#{i}] => #{iVal_a_r[i]}")
        end

        #
        # Try setting each bit to its value.
        #
        bs = BitString.new(sVal)
        lVal.times do |i|
          bs[i] = iVal_a_r[i]
          assert_equal(iVal_a_r[i],
                       bs[i],
                       "Test setting bit to itself " +
                       "[#{i}] = #{iVal_a_r[i]}; [#{i}] => #{iVal_a_r[i]}")
        end

        #
        # Try setting each bit to its complement.
        #
        bs = BitString.new(sVal)
        lVal.times do |i|
          pre = bs.to_s
          bs[i] = ~ bs[i]
          post = bs.to_s
          assert_not_equal(iVal_a_r[i],
                           bs[i],
                           "Test setting bit to its complement " +
                           "[#{i}] = ~[#{i}] != #{iVal_a_r[i]}\n" +
                           "pre=[#{pre}] post=[#{post}] sVal=[#{sVal}]")
        end

        #
        # Try fetching with indices beyond the bounds.
        #
        msg = "Test no exception from unbounded '#{sVal}'[#{lVal + 10}]"
        assert_nothing_raised(msg)  do
          bs[lVal + 10]
        end
        msg = "Test IndexError exception from unbounded '#{sVal}'[-1]"
        assert_raise(IndexError, msg) do
          bs[-1]
        end
        bs = BitString.new(sVal, lVal)
        msg = "Test IndexError exception from bounded '#{sVal}'[#{lVal + 10}]"
        assert_raise(IndexError, msg) do
          bs[lVal + 10]
        end
        msg = "Test IndexError exception from bounded '#{sVal}'[-1]"
        assert_raise(IndexError, msg) do
          bs[-1]
        end
      end
    end

    #
    # Now let's try ranges for indexing.  First, use [start..end] syntax.
    #
    def test_008_ranges()
      TestVals.each do |sVal|
        length = sVal.length
        (length - 2).times do |width|
          width += 2
          bs = BitString.new(sVal)
          #
          # Test subranging n bits at a time in a fetch
          #
          (length - width + 1).times do |i|
            excerpt = sVal[length-width-i,width].to_i(2)
            rng = i..i+width-1
            assert_equal(excerpt,
                         bs[rng].to_i,
                         'Test fetching bitstring subrange ' +
                         "'#{bs.to_s}'[#{rng}] => '#{excerpt}'\n" +
                         "(sVal='#{sVal}', length=#{length}, " +
                         "width=#{width}, i=#{i})")
          end
          #
          # Now try setting that range to its complement
          #
          (length - width + 1).times do |i|
            bs = BitString.new(sVal)
            excerpt = (~ sVal[length-width-i,width].to_i(2)) & (2**width - 1)
            rng = i..i+width-1
            bs[rng] = excerpt
            assert_equal(excerpt,
                         bs[rng].to_i,
                         'Test bitstring subrange after set' +
                         "'#{bs.to_s}'[#{rng}] => '#{excerpt}'")
          end

          #
          # Now do the same with a bounded bitstring.
          #
          bs = BitString.new(sVal, length)
          #
          # Test subranging n bits at a time in a fetch
          #
          (length - width + 1).times do |i|
            excerpt = sVal[length-width-i,width].to_i(2)
            rng = i..i+width-1
            assert_equal(excerpt,
                         bs[rng].to_i,
                         'Test fetching bitstring subrange ' +
                         "'#{bs.to_s}'[#{rng}] => '#{excerpt}'\n" +
                         "(sVal='#{sVal}', length=#{length}, " +
                         "width=#{width}, i=#{i})")
          end
          #
          # Now try setting that range to its complement
          #
          (length - width + 1).times do |i|
            bs = BitString.new(sVal, length)
            excerpt = (~ sVal[length-width-i,width].to_i(2)) & (2**width - 1)
            rng = i..i+width-1
            bs[rng] = excerpt
            assert_equal(excerpt,
                         bs[rng].to_i,
                         'Test bitstring subrange after set' +
                         "'#{bs.to_s}'[#{rng}] => '#{excerpt}'")
          end
        end
      end
    end

    #
    # Now try the [start,count] format.
    #
    def test_009_ranges()
      TestVals.each do |sVal|
        bs = BitString.new(sVal)
        length = sVal.length
        (length - 2).times do |width|
          width += 2
          #
          # Test subranging n bits at a time
          #
          (length - width + 1).times do |i|
            excerpt = sVal[length-width-i,width].to_i(2)
            assert_equal(excerpt,
                         bs[i,width].to_i,
                         'Test bitstring subrange ' +
                         "'#{bs.to_s}'[#{i},#{width}] =>'#{excerpt}'")
          end
        end
      end
    end

    #
    # Verify that the 'least significant bit' method is returning the
    # right value.
    #
    def test_010_lsb()
      TestVals.each do |sVal|
        iVal = sVal.to_i(2)
        bs = BitString.new(sVal)
        assert_equal(sVal[-1,1].to_i(2),
                     bs.lsb,
                     "Test lsb(#{sVal}) => #{sVal[-1,1].to_i(2)}")
      end
    end

    #
    # Test the msb (most significant bit) method, which only works on
    # bounded strings.
    #
    def test_011_msb()
      TestVals.each do |sVal|
        bs = BitString.new(sVal)
        msg = "Test RuntimeError raised by unbounded msb()"
        assert_raise(RuntimeError, msg) do
          bs.msb
        end
        bs = BitString.new(sVal, sVal.length)
        assert_equal(sVal[0,1].to_i,
                     bs.msb,
                     "Test bounded msb(#{sVal}) => #{sVal[0,1].to_i}")
      end
    end

    #
    # Test growing the bit string, in either direction.
    #
    def test_012_grow()
      nBits = 10
      TestVals.each do |sVal|
        bs = BitString.new(sVal)
        msg = "Test IndexError raised for unbounded grow(#{-nBits})"
        assert_raise(IndexError, msg) do
          bs.grow(-nBits)
        end
        msg = "Test IndexError raised for unbounded grow!(#{-nBits})"
        assert_raise(IndexError, msg) do
          bs.grow!(-nBits)
        end
        msg = "Test RuntimeError raised for unbounded grow(#{nBits})"
        assert_raise(RuntimeError, msg) do
          bs.grow(nBits)
        end
        msg = "Test RuntimeError raised for unbounded grow!(#{nBits})"
        assert_raise(RuntimeError) do
          bs.grow!(nBits)
        end

        #
        # Loop for the default value.
        #
        [ nil, 0, 1 ].each do |defval|
          bcmd = "bs.grow(#{nBits}"
          bcmd += ", #{defval}" unless (defval.nil?)
          [ nil, 'BitString::HIGH_END', 'BitString::LOW_END' ].each do |dir|
            dir = nil if (defval.nil?)
            cmd = bcmd
            cmd += ", #{dir}" unless (dir.nil?)
            cmd += ')'
            idir = dir
            eval("idir = #{dir}") unless (dir.nil?)
            #
            # Create the base bitstring, and then get the grown copy
            #
            bs = BitString.new(sVal, sVal.length)
            tbs = eval(cmd)
            cmd2 = cmd.sub(/(grow)\(/, '\1!(')
            eval(cmd2)
            cmd.sub!(/^bs/, '')
            cmd2.sub!(/^bs/, '')
            assert_equal(sVal.length + nBits,
                         tbs.length,
                         "Test '#{sVal}'#{cmd}.length (#{tbs.to_s})")
            assert_equal(sVal.length + nBits,
                         bs.length,
                         "Test '#{sVal}'#{cmd2}.length (#{bs.to_s})")
            if ((defval.nil? && idir.nil?) ||
                ((defval == 0) &&
                 (idir.nil? || (idir == BitString::HIGH_END))))
              #
              # grow(nBits)
              # grow(nBits, 0)
              # grow(nBits, 0, BitString::HIGH_END)
              #
              assert_equal(0,
                           tbs[sVal.length,nBits].to_i,
                           "Test '#{sVal}'#{cmd} fills high 0 (#{tbs.to_s})")
              assert_equal(0,
                           bs[sVal.length,nBits].to_i,
                           "Test '#{sVal}'#{cmd2} fills high 0 " +
                           "(#{tbs.to_s})")

              assert_equal(0,
                           tbs[sVal.length,nBits].to_i,
                           "Test '#{sVal}'#{cmd} fills high 0 (#{tbs.to_s})")
              assert_equal(0,
                           bs[sVal.length,nBits].to_i,
                           "Test '#{sVal}'#{cmd2} fills high 0 (#{bs.to_s})")
            elsif ((defval == 1) &&
                   (idir.nil? || (idir == BitString::HIGH_END)))
              #
              # grow(nBits, 1)
              # grow(nBits, 1, BitString::HIGH_END)
              #
              assert_equal(2**nBits - 1,
                           tbs[sVal.length,nBits].to_i,
                           "Test '#{sVal}'#{cmd} fills high 1 (#{tbs.to_s})")
              assert_equal(2**nBits - 1,
                           bs[sVal.length,nBits].to_i,
                           "Test '#{sVal}'#{cmd2} fills high 1 (#{bs.to_s})")
            elsif ((defval == 0) && (idir == BitString::LOW_END))
              #
              # grow(nBits, 0, BitString::LOW_END)
              #
              assert_equal(0,
                           tbs[0,nBits].to_i,
                           "Test '#{sVal}'#{cmd} fills low 0 (#{tbs.to_s})")
              assert_equal(0,
                           bs[0,nBits].to_i,
                           "Test '#{sVal}'#{cmd2} fills low 0 (#{bs.to_s})")

              assert_equal(sVal.to_i(2),
                           tbs[nBits,sVal.length].to_i,
                           "Test '#{sVal}'#{cmd} properly shifts and " +
                           "low fills 0 (#{tbs.to_s})")
              assert_equal(sVal.to_i(2),
                           bs[nBits,sVal.length].to_i,
                           "Test '#{sVal}'#{cmd2} properly shifts and " +
                           "low fills 0 (#{bs.to_s})")
            elsif ((defval == 1) && (idir == BitString::LOW_END))
              #
              # grow(nBits, 1, BitString::LOW_END)
              #
              assert_equal(2**nBits - 1,
                           tbs[0,nBits].to_i,
                           "Test '#{sVal}'#{cmd} fills low 1 (#{tbs.to_s})")
              assert_equal(2**nBits - 1,
                           bs[0,nBits].to_i,
                           "Test '#{sVal}'#{cmd2} fills low 1 (#{bs.to_s})")

              assert_equal(sVal.to_i(2),
                           tbs[nBits,sVal.length].to_i,
                           "Test '#{sVal}'#{cmd} properly shifts and " +
                           "low fills 1 (#{tbs.to_s})")
              assert_equal(sVal.to_i(2),
                           bs[nBits,sVal.length].to_i,
                           "Test '#{sVal}'#{cmd2} properly shifts and " +
                           "low fills 1 (#{bs.to_s})")
            else
              assert(false, "Missed case '#{sVal}'#{cmd}\n" +
                     "sVal=#{tbs.to_s}\n" +
                     "defval=#{defval.inspect}\n" +
                     "dir=#{dir.inspect}")
            end
          end
        end
      end
    end

    #
    # Test shrinking the bitstring (making it shorter).
    #
    def test_013_shrink()
      TestVals.each do |sVal|
        nBits = [9, sVal.length].min + 1
        bs = BitString.new(sVal)
        assert_raise(IndexError) do
          bs.shrink(-nBits)
        end
        assert_raise(IndexError) do
          bs.shrink!(-nBits)
        end
        assert_raise(RuntimeError) do
          bs.shrink(nBits)
        end
        assert_raise(RuntimeError) do
          bs.shrink!(nBits)
        end
        bs = BitString.new(sVal, sVal.length)
        assert_raise(RuntimeError) do
          bs.shrink(sVal.length)
        end
        assert_raise(RuntimeError) do
          bs.shrink!(sVal.length)
        end

        #
        # Loop for the default value.
        #
        [ nil, 0, 1 ].each do |defval|
          bcmd = "bs.shrink(#{nBits}"
          [ nil, 'BitString::HIGH_END', 'BitString::LOW_END' ].each do |dir|
            cmd = bcmd
            cmd += ", #{dir}" unless (dir.nil?)
            cmd += ')'
            idir = dir
            eval("idir = #{dir}") unless (dir.nil?)
            #
            # Create the base bitstring, and then get the shrunken copy
            #
            bs = BitString.new(sVal, sVal.length)
            tbs = eval(cmd)
            cmd2 = cmd.sub(/(shrink)\(/, '\1!(')
            eval(cmd2)
            cmd.sub!(/^bs/, '')
            cmd2.sub!(/^bs/, '')
            assert_equal(sVal.length - nBits,
                         tbs.length,
                         "Test '#{sVal}'#{cmd}.length (#{tbs.to_s})")
            assert_equal(sVal.length - nBits,
                         bs.length,
                         "Test '#{sVal}'#{cmd2}.length (#{bs.to_s})")
            newLength = sVal.length - nBits
            if (idir.nil? || (idir == BitString::HIGH_END))
              #
              # shrink(nBits)
              # shrink(nBits, BitString::HIGH_END)
              #
              assert_equal(sVal[nBits,newLength].to_i(2), 
                           tbs.to_i,
                           "Test '#{sVal}'#{cmd} properly truncates " +
                           "high (#{tbs.to_s})")
              assert_equal(sVal[nBits,newLength].to_i(2),
                           bs.to_i,
                           "Test '#{sVal}'#{cmd2} properly truncates " +
                           "high (#{bs.to_s})")

            elsif (idir == BitString::LOW_END)
              #
              # shrink(nBits, BitString::LOW_END)
              #
              assert_equal(sVal[0,newLength].to_i(2),
                           tbs.to_i,
                           "Test '#{sVal}'#{cmd} properly shifts " +
                           "low (#{tbs.to_s})")
              assert_equal(sVal[0,newLength].to_i(2),
                           bs.to_i,
                           "Test '#{sVal}'#{cmd2} properly shifts " +
                           "low (#{bs.to_s})")
            else
              assert(false, "Missed case '#{sVal}'#{cmd}\n" +
                     "sVal=#{tbs.to_s}\n" +
                     "dir=#{dir.inspect}")
            end
          end
        end
      end
    end

    #
    # Try resizing bitstrings.
    #
    def test_014_resize()
      TestVals.each do |sVal|
        #
        # First off, test resizing unbounded bitstrings.  The length()
        # method returns the number of digits from the most significant
        # 1.  We should be able to resize up or down, and the result will
        # be bounded.
        #
        bs = BitString.new(sVal)
        oLength = bs.length
        uLength  = sVal.sub(/^0+/, '').length
        #
        # Resize down.
        #
        nBits = [9, uLength / 2].min
        tbs = bs.resize(nBits)
        assert_equal(oLength,
                     bs.length,
                     "Test that resize original stays the same length")
        assert(tbs.bounded?,
               "Test that new downsized bitstring is bounded")
        assert_equal(nBits,
                     tbs.length,
                     "Test '#{sVal}'.resize(#{nBits} => '#{tbs.to_s}'.length")
        bs.resize!(nBits)
        assert(bs.bounded?, "Test that downsized bitstring is bounded")
        assert_equal(nBits,
                     bs.length,
                     "Test '#{sVal}'.resize(#{nBits} => '#{bs.to_s}'.length")

        #
        # Resize up.
        #
        bs = BitString.new(sVal, sVal.length)
        oLength = bs.length
        nBits = uLength * 2
        tbs = bs.resize(nBits)
        assert_equal(oLength,
                     bs.length,
                     "Test that resize original stays the same length")
        assert(tbs.bounded?, "Test that new upsized bitstring is bounded")
        assert_equal(nBits,
                     tbs.length,
                     "Test '#{sVal}'.resize(#{nBits} => '#{tbs.to_s}'.length")
        bs.resize!(nBits)
        assert(bs.bounded?, "Test that upsized bitstring is bounded")
        assert_equal(nBits,
                     bs.length,
                     "Test '#{sVal}'.resize(#{nBits} => '#{bs.to_s}'.length")
      end
    end

    #
    # Test rotating bitstrings (only works for bounded ones).
    #
    def test_015_rotate()
      bs = BitString.new('1001010010101110001101')
      msg = "Test RuntimeError raised for unbounded rotate(10)"
      assert_raise(RuntimeError, msg) do
        tbs = bs.rotate(10)
      end
      msg = "Test RuntimeError raised for unbounded rotate!(10)"
      assert_raise(RuntimeError, msg) do
        bs.rotate!(10)
      end
      TestVals.each do |sVal|
        lVal = sVal.length
        100.times do |i|
          bs = BitString.new(sVal, lVal)
          tBits = rand(lVal * (rand(5) + 1))
          nBits = tBits % lVal
          sign = rand(100) < 50 ? -1 : 1
          if (sign < 0)
            #
            # Rotating left
            #
            nsVal = sVal[nBits,lVal-nBits] + sVal[0,nBits]
          else
            #
            # Rotating right.
            #
            nsVal = sVal[lVal-nBits,nBits] + sVal[0,lVal-nBits]
          end
          tbs = bs.rotate(tBits * sign)
          assert_equal(sVal,
                       bs.to_s,
                       "Test that rotate(#{tBits * sign}) " +
                       "doesn't alter the source")
          assert_equal(nsVal,
                       tbs.to_s,
                       "Test '#{sVal}'.rotate(#{tBits * sign}) => '#{nsVal}'")
          bs.rotate!(tBits * sign)
          assert_equal(nsVal,
                       bs.to_s,
                       "Test '#{sVal}'.rotate!(#{tBits * sign}) => '#{nsVal}'")
        end
      end
    end

    #
    # @TODO
    #
    # slice() and slice!()
    #
    def test_016_slice()
      TestVals.each do |sVal|
        iVal = sVal.to_i(2)
        bs = BitString.new(sVal)
      end
    end

    #
    # Test the masking.
    #
    def test_017_mask()
      TestVals.each do |sVal|
        iVal = sVal.to_i(2)
        bs = BitString.new(sVal)
      end
    end

    #
    # Test the each() method.
    #
    def test_018_each()
      TestVals.each do |sVal|
        bs = BitString.new(sVal)
        bs.each do |pos,val|
          assert_equal(val,
                       bs[pos],
                       "Test unbounded each block(#{pos}, #{val})")
        end
        #
        # And again for a bounded value.
        #
        bs = BitString.new(sVal, sVal.length)
        bs.each do |pos,val|
          assert_equal(val,
                       bs[pos],
                       "Test bounded each block(#{pos}, #{val})")
        end
      end
    end

  end

end                             # module Tests
