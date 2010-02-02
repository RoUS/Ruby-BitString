require 'rubygems'
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/test_data.rb'

#
# Test the methods inherited from the Enumerable mixin.
#

module Tests

#inject
#member?
#reject
#to_set
#zip

  class Test_BitStrings < Test::Unit::TestCase

    #
    # The all? method returns true IFF every iteration of the block returns
    # a true value.
    #
    def test_xxx_all?()
      return unless (BitString.new.respond_to?(:all?))
      TestVals.each do |sVal|
        #
        # Start with unbounded bitstrings.
        #
        bs = BitString.new(sVal)
        assert(bs.all? { |v| true },
               "Test unbounded '#{sVal}'.all? true == true")
        assert(! bs.all? { |v| false },
               "Test unbounded '#{sVal}'.all? false == false")
        tick = 0
        assert(! bs.all? { |v| ((tick += 1) % 2) == 0 },
               "Test unbounded '#{sVal}'.all? sometimes == false")
        #
        # Repeat for bounded strings.
        #
        bs = BitString.new(sVal, sVal.length)
        assert(bs.all? { |v| true },
               "Test bounded '#{sVal}'.all? true == true")
        assert(! bs.all? { |v| false },
               "Test bounded '#{sVal}'.all? false == false")
        tick = 0
        assert(! bs.all? { |v| ((tick += 1) % 2) == 0 },
               "Test bounded '#{sVal}'.all? sometimes == false")
      end
    end

    #
    # Test that the any? method works. (Returns true if any iteration of
    # the block does.)
    #
    def test_xxx_any?()
      return unless (BitString.new.respond_to?(:any?))
      TestVals.each do |sVal|
        #
        # Start with unbounded bitstrings.
        #
        bs = BitString.new(sVal)
        assert(bs.any? { |v| true },
               "Test unbounded '#{sVal}'.any? true == true")
        assert(! bs.any? { |v| false },
               "Test unbounded '#{sVal}'.any? false == false")
        tick = 0
        assert(bs.any? { |v| v == sVal[-1,1].to_i(2) },
               "Test unbounded '#{sVal}'.any? sometimes == true")
        #
        # Repeat for bounded strings.
        #
        bs = BitString.new(sVal, sVal.length)
        assert(bs.any? { |v| true },
               "Test bounded '#{sVal}'.any? true == true")
        assert(! bs.any? { |v| false },
               "Test bounded '#{sVal}'.any? false == false")
        tick = 0
        assert(bs.any? { |v| v == sVal[-1,1].to_i(2) },
               "Test bounded '#{sVal}'.any? sometimes == true")
      end
    end

    def test_xxx_collect()
      return unless (BitString.new.respond_to?(:collect))
      TestVals.each do |sVal|
        #
        # Unbounded first.
        #
        bs = BitString.new(sVal)
        tVal = sVal.sub(/^0+(.)/, '\1').reverse
        assert_equal(tVal.split(//),
                     bs.collect { |v| v.to_s(2) },
                     "Test that unbounded '#{sVal}'.collect works")
        #
        # Now bounded..
        #
        bs = BitString.new(sVal, sVal.length)
        tVal = sVal.reverse
        assert_equal(tVal.split(//),
                     bs.collect { |v| v.to_s(2) },
                     "Test that bounded '#{sVal}'.collect works")
      end
    end

    #
    # Returns the first value for which the block doesn't return false.
    # If all iterations return false, .detect() calls the proc specified
    # by the ifnone argument and returns its result; otherwise it returns
    # nil.
    #
    def test_xxx_detect()
      return unless (BitString.new.respond_to?(:detect))
      TestVals.each do |sVal|
        #
        # Start with unbounded bitstrings.
        #
        bs = BitString.new(sVal)
        assert_equal(sVal[-1,1].to_i(2),
                     bs.detect { |v| true },
                     "Test unbounded '#{sVal}'.detect {true} == '#{sVal[-1,1]}'")
        assert_nil(bs.detect { |v| false },
                   "Test unbounded '#{sVal}'.detect {false} == nil")
        assert_equal(IfNoneCalled,
                     bs.detect(IfNone) { |v| false },
                     "Test unbounded '#{sVal}'.detect(ifnone) {false} == " +
                     "'#{IfNoneCalled}'")
        #
        # Now bounded ones.
        #
        bs = BitString.new(sVal, sVal.length)
        assert_equal(sVal[-1,1].to_i(2),
                     bs.detect { |v| true },
                     "Test bounded '#{sVal}'.detect {true} == '#{sVal[-1,1]}'")
        assert_nil(bs.detect { |v| false },
                   "Test bounded '#{sVal}'.detect {false} == nil")
        assert_equal(IfNoneCalled,
                     bs.detect(IfNone) { |v| false },
                     "Test bounded '#{sVal}'.detect(ifnone) {false} == " +
                     "'#{IfNoneCalled}'")
      end
    end

    #
    # Like .each, only passes two arguments.
    #
    def test_xxx_each_with_index()
      return unless (BitString.new.respond_to?(:each_with_index))
      TestVals.each do |sVal|
        #
        # Unbounded first..
        #
        bs = BitString.new(sVal)
        bs.each_with_index do |val,pos|
          assert_equal(sVal[-1-pos,1],
                       val.to_s,
                       "Test unbounded '#{sVal}'.each_with_index" +
                       "(#{val},#{pos}) == #{sVal[-1-pos,1]}")
        end
        #
        # Now bounded strings.
        #
        bs = BitString.new(sVal, sVal.length)
        bs.each_with_index do |val,pos|
          assert_equal(sVal[-1-pos,1],
                       val.to_s,
                       "Test bounded '#{sVal}'.each_with_index" +
                       "(#{val},#{pos}) == #{sVal[-1-pos,1]}")
        end
      end
    end

    #
    # Convert to an array.  (Equivalent to .to_a ?)
    #
    def test_xxx_entries()
      return unless (BitString.new.respond_to?(:entries))
      TestVals.each do |sVal|
        #
        # Unbounded.
        #
        bs = BitString.new(sVal)
        sVal_a = sVal.sub(/^0+(.)/, '\1').reverse.split(//).collect { |v| v.to_i(2) }
        assert_equal(sVal_a,
                     bs.entries,
                     "Test unbounded '#{sVal}'.entries")
        #
        # Bounded.
        #
        bs = BitString.new(sVal, sVal.length)
        sVal_a = sVal.reverse.split(//).collect { |v| v.to_i(2) }
        assert_equal(sVal_a,
                     bs.entries,
                     "Test bounded '#{sVal}'.entries")
      end
    end

    def test_xxx_find()
      #
      # Same as .detect(), don't bother to test.
      #
    end

    #
    # Like .find/.detect except it returns all matching values, not just
    # the first.
    #
    def test_xxx_find_all()
      return unless (BitString.new.respond_to?(:find_all))
      TestVals.each do |sVal|
        #
        # Unbounded.
        #
        bs = BitString.new(sVal)
        assert(bs.find_all { |v| false }.empty?,
               "Test unbounded '#{sVal}'.find_all{false} == []")
        #
        # .population should have been tested in test_basic
        #
        assert_equal(bs.population(0),
                     bs.find_all { |v| v == 0 }.length,
                     "Test unbounded '#{sVal}.find_all{0}.length " +
                     "== population(0)")
        assert_equal(bs.population(1),
                     bs.find_all { |v| v == 1 }.length,
                     "Test unbounded '#{sVal}.find_all{1}.length " +
                     "== population(1)")
        sVal_t = sVal.sub(/^0+(.)/, '\1').reverse.split(//)
        tick = 0
        sVal_t = sVal_t.find_all { |v| ((tick += 1) % 2) == 0 }
        sVal_t.collect! { |v| v.to_i(2) }
        tick = 0
        assert_equal(sVal_t,
                     bs.find_all { |v| ((tick += 1) % 2) == 0 },
                     "Test unbounded '#{sVal}'.find_all(alt) works")
        #
        # Bounded.
        #
        bs = BitString.new(sVal, sVal.length)
        assert(bs.find_all { |v| false }.empty?,
               "Test bounded '#{sVal}'.find_all{false} == []")
        assert_equal(bs.population(0),
                     bs.find_all { |v| v == 0 }.length,
                     "Test bounded '#{sVal}.find_all{0}.length " +
                     "== population(0)")
        assert_equal(bs.population(1),
                     bs.find_all { |v| v == 1 }.length,
                     "Test bounded '#{sVal}.find_all{1}.length " +
                     "== population(1)")
        sVal_t = sVal.reverse.split(//)
        tick = 0
        sVal_t = sVal_t.find_all { |v| ((tick += 1) % 2) == 0 }
        sVal_t.collect! { |v| v.to_i(2) }
        tick = 0
        assert_equal(sVal_t,
                     bs.find_all { |v| ((tick += 1) % 2) == 0 },
                     "Test bounded '#{sVal}'.find_all(alt) works")
      end
    end

    #
    # No grep here..
    #
    def test_xxx_grep()
      return unless (BitString.new.respond_to?(:grep))
      assert(false, '###FAIL! .grep not supported but .respond_to? is true!')
    end

    #
    # Only 0 and 1 will ever succeed..
    #
    def test_xxx_include?()
      return unless (BitString.new.respond_to?(:include?))
      TestVals.each do |sVal|
        #
        # Unbounded.
        #
        bs = BitString.new(sVal)
        assert(! bs.include?(2),
               "Test unbounded '#{sVal}'.include?(2) fails")
        [0, 1].each do |val|
          if (bs.population(val) != 0)
            assert(bs.include?(val),
                   "Test unbounded '#{sVal}'.include?(#{val}) succeeds")
          else
            assert(! bs.include?(val),
                   "Test unbounded '#{sVal}'.include?(#{val}) fails")
          end
        end
        #
        # Bounded.
        #
        bs = BitString.new(sVal, sVal.length)
        assert(! bs.include?(2),
               "Test bounded '#{sVal}'.include?(2) fails")
        [0, 1].each do |val|
          if (bs.population(val) != 0)
            assert(bs.include?(val),
                   "Test bounded '#{sVal}'.include?(#{val}) succeeds")
          else
            assert(! bs.include?(val),
                   "Test bounded '#{sVal}'.include?(#{val}) fails")
          end
        end
      end
    end

    #
    # Test .inject
    #
    def test_xxx_inject()
      return unless (BitString.new.respond_to?(:inject))
      TestVals.each do |sVal|
        bs = BitString.new(sVal)
        result = bs.inject { |memo,val| memo += val }
        assert_equal(bs.population(1),
                     result,
                     "Test unbounded '#{sVal}'.inject { memo + 1s}")
        result = bs.inject(-20) { |memo,val| memo += val }
        assert_equal(bs.population(1) - 20,
                     result,
                     "Test unbounded '#{sVal}'.inject(-20) { memo + 1s}")
        #
        # This one is failing because of the issue with the leading
        # zeroes being stripped and the initial memo value being set
        # from the LSB.  I think.
        #
        result = bs.inject { |memo,val| memo += (val == 0 ? 1 : 0) }
        assert_equal(bs.population(0),
                     result,
                     "Test unbounded '#{sVal}'.inject { memo + 0s}")
        result = bs.inject(-20) { |memo,val| memo += (val == 0 ? 1 : 0) }
        assert_equal(bs.population(0) - 20,
                     result,
                     "Test unbounded '#{sVal}'.inject(-20) { memo + 0s}")
      end
    end

    def test_xxx_map()
      #
      # Same as .collect so don't bother to test.
      #
    end

    def test_xxx_max()
      return unless (BitString.new.respond_to?(:max))
      assert(true)
    end

    def test_xxx_member?()
      return unless (BitString.new.respond_to?(:member?))
      assert(true)
    end

    def test_xxx_min()
      return unless (BitString.new.respond_to?(:min))
      assert(true)
    end

    def test_xxx_partition()
      return unless (BitString.new.respond_to?(:partition))
      assert(true)
    end

    def test_xxx_reject()
      return unless (BitString.new.respond_to?(:reject))
      assert(true)
    end

    #
    # Test the select() method.
    #
    def test_xxx_select()
      TestVals.each do |sVal|
        bs = BitString.new(sVal)
        aVal = bs.select { |bit| true }
        aVal = aVal.collect { |num| num.to_s }.join('').reverse
        sVal_e = sVal.gsub(/^0+(.)/, '\1')
        assert_equal(sVal_e,
                     aVal,
                     "Test unbounded select block('#{sVal}')")
        #
        # And again for a bounded value.
        #
        bs = BitString.new(sVal, sVal.length)
        aVal = bs.select { |bit| true }
        aVal = aVal.collect { |num| num.to_s }.join('').reverse
        assert_equal(sVal,
                     aVal,
                     "Test bounded select block('#{sVal}')")
      end
    end

    #
    # slice()
    #
    def test_xxx_slice()
      return unless (BitString.new.respond_to?(:slice))
      TestVals.each do |sVal|
        bs = BitString.new(sVal)
        sVal_r = sVal.reverse
        sVal_l = sVal.length
        (sVal_l - 1).times do |pos|
          (sVal_l - pos).times do |width|
            width += 1
            nbs = bs.slice(pos, width)
            bsPiece = nbs.to_s
            #
            # nbs is now bounded (that's what slice() does), so it should no
            # longer match the original under any conditions.
            #
            assert_not_equal(bs,
                             nbs,
                             "Verify that slice() doesn't change the original")
            sPiece = sVal_r[pos,width].reverse
            assert_equal(sPiece,
                         bsPiece,
                         "Test '#{sVal}'.slice(#{pos},#{width}) == '#{sPiece}'")
          end
        end
      end
    end

    #
    # slice!()
    #
    def test_xxx_slice!()
      return unless (BitString.new.respond_to?(:slice!))
      TestVals.each do |sVal|
        sVal_r = sVal.reverse
        sVal_l = sVal.length
        (sVal_l - 1).times do |pos|
          (sVal_l - pos).times do |width|
            width += 1
            bs = BitString.new(sVal)
            bs.slice!(pos, width)
            bsPiece = bs.to_s
            #
            # Slicing results in a bounded bitstring, so don't strip the
            # leading zeroes.
            #
            sPiece = sVal_r[pos,width].reverse
            assert_equal(sPiece,
                         bsPiece,
                         "Test '#{sVal}'.slice!(#{pos},#{width}) == '#{sPiece}'")
          end
        end
      end
    end

    def test_xxx_sort()
      return unless (BitString.new.respond_to?(:sort))
      assert(true)
    end

    def test_xxx_sort_by()
      return unless (BitString.new.respond_to?(:sort_by))
      assert(true)
    end

    def test_xxx_zip()
      return unless (BitString.new.respond_to?(:zip))
      assert(true)
    end

  end                           # class Test_BitStrings

end                           # module Tests
