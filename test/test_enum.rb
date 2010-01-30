require 'rubygems'
require File.dirname(__FILE__) + '/test_helper.rb'
require File.dirname(__FILE__) + '/test_data.rb'

#
# Test the methods inherited from the Enumerable mixin.
#

module Tests

#all>
#any?
#collect
#detect
#each_with_index
#entries
#find
#find_all
#include?
#inject
#length
#map
#member?
#reject
#select
#slice
#slice!
#to_set
#zip

  class Test_BitStrings < Test::Unit::TestCase

    def test_xxx_all?()
      return unless (BitString.new.respond_to?(:all?))
      assert(true)
    end

    def test_xxx_any?()
      return unless (BitString.new.respond_to?(:any?))
      assert(true)
    end

    def test_xxx_collect()
      return unless (BitString.new.respond_to?(:collect?))
      assert(true)
    end

    def test_xxx_detect()
      return unless (BitString.new.respond_to?(:detect))
      assert(true)
    end

    def test_xxx_each_with_index()
      return unless (BitString.new.respond_to?(:each_with_index))
      assert(true)
    end

    def test_xxx_entries()
      return unless (BitString.new.respond_to?(:entries))
      assert(true)
    end

    def test_xxx_find()
      return unless (BitString.new.respond_to?(:find))
      assert(true)
    end

    def test_xxx_find_all()
      return unless (BitString.new.respond_to?(:find_all))
      assert(true)
    end

    def test_xxx_grep()
      return unless (BitString.new.respond_to?(:grep))
      assert(true)
    end

    def test_xxx_include?()
      return unless (BitString.new.respond_to?(:include?))
      assert(true)
    end

    def test_xxx_inject()
      return unless (BitString.new.respond_to?(:inject))
      assert(true)
    end

    def test_xxx_map()
      return unless (BitString.new.respond_to?(:map))
      assert(true)
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

    def test_xxx_select()
      return unless (BitString.new.respond_to?(:select))
      assert(true)
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
