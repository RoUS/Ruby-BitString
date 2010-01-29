#
# = bitstring.rb - Bounded and unbounded bit strings
#
# Author::    Ken Coar
# Copyright:: Copyright © 2010 Ken Coar
# License::   Apache Licence 2.0
#
# == Synopsis
#
#    require 'rubygems'
#    require 'bitstring'
#    bString = BitString.new([initial-value], [bitcount])
#    bString = BitString.new(bitcount) { |index| block }
#
# == Description
#
# The <i>BitString</i> package provides a class for handling a series
# of bits as an array-like structure.  Bits are addressable individually
# or as subranges.
#
#--
# Copyright © 2010 Ken Coar
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License. You may
# obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied. See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'rubygems'
require 'versionomy'

require 'bitstring/operators'

#--
# @TODO items (or at least look at)
#
# Methods (unique to bitstrings):
#    rotate           # Rotate a bounded bitstring
#    rotate!          # Rotate a bounded bitstring in place
#    ones             # Count of bits set to 1
#    zeroes           # Count of bits set to 0
#    to_i             # Convert to an integer value
#    to_s             # Represent as a string of '1' and '0'
#
# Methods (based on Array):
#    all?             #
#    any?             #
#    assoc            #
#    at               #
#    clear            #
#    collect          #
#    collect!         #
#    compact          #
#    compact!         #
#    concat           #
#    delete           # Meaningless for bitstrings
#    delete_at        # Meaningless for bitstrings
#    delete_if        # Meaningless for bitstrings
#    detect           #
#    each             #
#    each_index       #
#    each_with_index  #
#    empty?           # Meaningless for bitstrings
#    entries          #
#    fetch            #
#    fill             #
#    find             #
#    find_all         #
#    first            #
#    flatten          #
#    flatten!         #
#    grep             #
#    include?         #
#    index            #
#    indexes          #
#    indices          #
#    inject           #
#    insert           #
#    join             #
#    last             #
#    length           #
#    map              #
#    map!             #
#    max              # Meaningless for bitstrings
#    member?          #
#    min              # Meaningless for bitstrings
#    nitems           #
#    pack             #
#    partition        #
#    pop              #
#    push             #
#    rassoc           #
#    reject           #
#    reject!          #
#    replace          #
#    reverse          #
#    reverse!         #
#    reverse_each     #
#    rindex           #
#    select           #
#    shift            #
#    size             #
#    sort             #
#    sort!            #
#    sort_by          #
#    to_ary           #
#    transpose        #
#    uniq             #
#    uniq!            #
#    unshift          #
#    values_at        #
#    zip              #
#
#++

#
# It's sort of like a fake a subclass of Integer solely to
# differentiate bitstrings.
#
class BitString

  Version = Versionomy.parse('0.1.0')
  VERSION = Version.to_s

  #
  # Other constants:
  #

  #
  # Values for <i>grow</i> and <i>shrink</i> methods.
  #
  LOW_END = :low                # Grow/shrink at least significant end
  HIGH_END = :high              # Grow/shrink at mose significant end

  # :stopdoc:
  #
  # These classes are part of our internal error condition handling
  # mechanism, and aren't intended to be used externally.
  #
  class InternalError < Exception
    #
    # Used internally only -- except for internal consistency errors.
    #
  end                           # class InternalError

  class BadDigit < InternalError
    #
    # Turned into an ArgumentError.
    #
  end                           # class BadDigit

  class BitsRInts < InternalError
    #
    # Turned into an ArgumentError.
    #
  end                           # class BitsRInts

  class BogoIndex < InternalError
    #
    # Turned into an IndexError.
    #
  end                           # class BogoIndex

  class NeedGPS < InternalError
    #
    # Turned into an ArgumentError.
    #
  end                           # class NeedGPS

  class NoDeficitBits < InternalError
    #
    # Turned into an IndexError.
    #
  end                           # class NoDeficitBits

  class OuttasightIndex < InternalError
    #
    # Turned into an IndexError.
    #
  end                           # class OuttasightIndex

  class UnboundedNonsense < InternalError
    #
    # Turned into a RuntimeError.
    #
  end                           # class UnboundedNonsense

  class UnInterable < InternalError
    #
    # Turned into a RuntimeError.
    #
  end                           # class UnInterable

  class WrongNargs < InternalError
    #
    # Turned into an ArgumentError.
    #
  end                           # class WrongNargs

  # :startdoc:
  #
  # We want a bunch of Enumerable's methods..
  #
  include Enumerable

  #
  # ..but not all of them.  Some just don't make sense for bitstrings.
  #
  undef :grep, :max, :min, :partition, :sort, :sort_by

  #
  # <i>Boolean</i>.  Whether or not the bitstring is bounded and limited
  # to a specific length.  Read-only; set at object creation.
  #
  attr_reader   :bounded

  #
  # <i>Integer</i>.  Length of the bitstring.  Only meaningful for bounded
  # strings.  Read-only; set at object creation.
  #
  #attr_reader   :length

  #
  # === Description
  #
  # Create a new <i>BitString</i> object.  By default, it will be unbounded and
  # all bits clear.
  #
  # :call-seq:
  # new<i>([val], [length])</i> => <i>BitString</i>
  # new<i>(length) {|index| block }</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>val</i>] <i>Array</i>, <i>Integer</i>, <i>String</i>, or <i>BitString</i>. Initial value for the bitstring.  If a <i>String</i>, the value must contain only '0' and '1' characters; if an <i>Array</i>, all elements must be 0 or 1.  Default 0.
  # [<i>length</i>] <i>Integer</i>.  Length (number of bits) for a bounded bitstring.  Default 1.
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] Length specified but bitstring is unbounded.
  # [<tt>RangeError</tt>] Value is a string, but contains non-binary digits.
  #
  def initialize(*args_p, &block)
    #
    # Two constructor scenarios:
    #
    # 1. With a block and an optional length (defaults to 1)
    # 2. No block, and with value and length both optional.
    #
    # We don't do any type-checking on the arguments until later.
    #
    unless (block.nil?)
      #
      # We got a block; set up the constraints.  Bitstrings constructed
      # this way are bounded.
      #
      unless (args_p.length < 2)
        raise ArgumentError.new('only bitstring length ' +
                                'may be specified with a block')
      end
      @bounded = true
      @length = args_p.length > 0 ? args_p[0] : 1
    else
      #
      # Get value and possibly length from the argument list.
      #
      unless (args_p.length < 3)
        raise ArgumentError.new('wrong number of arguments ' +
                                '(must be 2 or fewer)')
      end
      val = args_p[0] || 0
      @length = args_p[1] if (@bounded = ! args_p[1].nil?)
    end
    #
    # Now do some validation on the arguments.
    #
    if (@bounded)
      unless ((@length = @length.to_i) > 0)
        raise ArgumentError.new('bitstring length must be greater than 0')
      end
    end
    if (block.nil?)
      #
      # We weren't passed a block, so get the info directly from the argument
      # list.
      #
      if (val.kind_of?(BitString))
        #
        # If we were passed a bitstring, convert it.
        #
        @value = val.to_i
      elsif (val.kind_of?(String))
        #
        # If we were given a String for the value, it must consist of valid
        # binary digits.
        #
        _raise(BadDigit, nil, val) unless (val.gsub(/[01]/, '').empty?)
        @value = val.to_i(2)
      elsif (val.kind_of?(Array))
        #
        # If we were given an array, make sure that all the values are
        # integers and either 1 or 0.
        #
        _raise(BadDigit, nil, val) unless ((val - [0, 1]).empty?)
        @value = val.join('').to_i(2)
      else
        #
        # Let's try to convert it to an integer from whatever class we
        # were passed.
        #
        unless (val.respond_to?(:to_i))
          raise ArgumentError.new('unable to determine bitstring ' +
                                  'value from ' +
                                  "\"#{val.to_s}\":#{val.class.name}")
        end
        @value = val.to_i
      end
    else      
      #
      # We were passed a block, so invoke it for each bit position to
      # determine that bit's value from the LSB of the result.
      #
      @value = 0
      @length.times { |i| self[i] = block.call(i).to_i & 1 }
    end
  end                           # def initialize

  #
  # === Description
  #
  # Raise a standard exception.
  #
  # :call-seq:
  # _raise<i>(exc, [msg])</i> => Exception raised
  #
  # === Arguments
  # [<i>exc</i>] <i>Exception</i>.  One of our 'known' repeated exceptions.
  # [<i>msg</i>] <i>String</i>.  Message to use if we don't have a canned one.
  #
  # === Exceptions
  # [<tt>InternalError</tt>] Called with something other than an exception.
  # As indicated.
  #
  def _raise(*args)             # :nodoc:
    exc = args.shift
    unless (exc.ancestors.include?(Exception))
      raise InternalError.new('asked to raise non-exception')
    end
    begin
      raise InternalError
    rescue InternalError => e
      if (args[0].kind_of?(String) && args[0].match(/%/))
        msg = sprintf(*args)
      elsif (args[0].kind_of?(String))
        msg = args.shift
      else
        msg = nil
      end

      mName = e.backtrace[1].match(/in \`(\S*)'/).captures[0]
      case exc.name.sub(/^.*::/, '')
      when 'BadDigit'
        if (msg.nil?)
          val = args[0].respond_to?(:to_s) ? args[0].to_s : args[0].inspect
          msg = "value ('#{val}':#{args[0].class.name}) contains invalid digits"
        end
        raise ArgumentError.new(msg)
      when 'BitsRInts'
        raise ArgumentError.new(msg || 'bitcount must be an integer')
      when 'BogoIndex'
        if (msg.nil?)
          val = args[0]
          msg = "illegal index value #{val.inspect}"
        end
        raise IndexError.new(msg)
      when 'NeedGPS'
        raise ArgumentError.new(msg ||
                                'invalid direction for operation')
      when 'NoDeficitBits'
        raise IndexError.new(msg || 'bitcount must be positive')
      when 'NotImplementedError'
        raise NotImplementedError.new(msg ||
                                      "method '#{mName}' not yet implemented")
      when 'OuttasightIndex'
        if (msg.kind_of?(Integer))
          msg = "index out of range: '#{msg.to_s}'"
        end
        raise IndexError.new(msg ||
                             'index out of range')
      when 'UnboundedNonsense'
        raise RuntimeError.new(msg ||
                               'operation only meaningful for ' +
                               'bounded bitstrings')
      when 'UnInterable'
        if (msg.nil?)
          val = args[0].respond_to?(to_s) ? args[0].to_s : args[0].inspect
          msg = "unable to reduce '#{val}':#{args[0].class.name} " +
            "to a binary value"
        end
        raise ArgumentError.new(msg)
      when 'WrongNargs'
        if (msg.nil?)
          val = args[0].respond_to?(:to_i) ? args[0].to_i : args[0].inspect
          req = args[1].respond_to?(:to_i) ? args[1].to_i : args[1].inspect
          msg = "wrong number of arguments (#{val} for #{req})"
        end
        raise ArgumentError.new(msg)
      else
        raise exc.new(msg)
      end
    end
  end                           # def _raise

  #
  # === Description
  #
  # Return a binary string representation of the value, zero filled
  # to the specified length.
  #
  # :call-seq:
  # _zfill<i>(value, length)</i> => <i>String</i>
  #
  # === Arguments
  # [<i>val</i>] <i>Integer</i> or <i>String</i>.  Value to be represented as a string of binary digits.
  # [<i>length</i>] <i>Integer</i>. Length of output string to return.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def _zfill(val_p, length_p)   # :nodoc:
    sVal = val_p.kind_of?(String) ? val_p : val_p.to_s(2)
    return sVal if (length_p.to_i <= 0)
    if (length_p > sVal.length)
      ('0' * (length_p - sVal.length)) + sVal
    elsif (length_p < sVal.length)
      sVal[-length_p, length_p]
    else
      sVal
    end
  end                           # def _zfill

  #
  # === Description
  #
  # Return a Boolean indicating whether the bitstring has a fixed length
  # (is bounded) or not.
  #
  # :call-seq:
  # bitstring.bounded?()
  #
  # === Arguments
  # <i>None</i>.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def bounded?()
    @bounded
  end                           # def bounded?()

  #
  # === Description
  #
  # Return a duplicate of the current bitstring -- with all bits cleared.
  #
  # :call-seq:
  # bitstring.clear<i>()</i> => <i>BitString</i>
  #
  # === Arguments
  # _None_.
  #
  # === Exceptions
  # _None_.
  #
  def clear()
    bs = dup
    bs.from_i(0)
    bs
  end                           # def clear()

  #
  # === Description
  #
  # Clear all the bits in the bitstring.
  #
  # :call-seq:
  # bitstring.clear!<i>()</i> => <i>BitString</i>
  #
  # === Arguments
  # _None_.
  #
  # === Exceptions
  # _None_.
  #
  def clear!()
    @value = 0
    self
  end                           # def clear!()

  #
  # === Description
  #
  # Treat the bitstring as an Integer and store its entire value at
  # once.
  #
  # :call-seq:
  # bitstring.from_i<i>(newval)</i>
  #
  # === Arguments
  # [<i>newval</i>] <i>Integer</i>. Value from whose bits those in the bitstring will be copied.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def from_i(newval)
    unless (newval.respond_to?(:to_i))
      what = newval.respond_to?(:to_s) ? newval.to_s : newval.inspect
      _raise(UnInterable, newval)
    end
    newval = newval.to_i
    newval &= 2**@length - 1 if (bounded?)
    @value = newval
  end                           # def from_i()

  #
  # === Description
  #
  # Return a new bitstring based on the current one, grown (made longer)
  # in one direction (toward the least significant bits) or the other.
  # Growing an unbounded string toward the high end is a no-op.
  #
  # Bits added are set to <i>defval</i> (default 0).
  #
  # :call-seq:
  # bitstring.grow<i>(bits, [defval], [direction])</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>bits</i>] <i>Integer</i> Number of bits to add.
  # [<i>defval</i>] <i>Integer</i> Value to which added bits should be set.
  # [<i>direction</i>] Either <i>BitString::HIGH_END</i> (the default) or <i>BitString::LOW_END</i>.  Indicates whether bits are added at the least or most significant end.  Growing with <i>BitString::LOW_END</i> results in the bitstring being shifted left.
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] <i>bits</i> isn't an integer, <i>defval</i> can't be reduced to a binary value, or <i>direction</i> isn't one of the defined values.
  # [<tt>IndexError</tt>] <i>bits</i> is negative or meaningless.
  # [<tt>RuntimeError</tt>] Can't grow an unbounded string at the high end.
  #
  def grow(bits=1, defval=0, direction=HIGH_END)
    unless (bits.kind_of?(Integer))
      _raise(BitsRInts)
    end
    unless (defval.respond_to?(:to_i))
      what = defval.respond_to?(:to_s) ? defval.to_s : defval.inspect
      _raise(UnInterable, defval)
    end
    unless ([HIGH_END, LOW_END].include?(direction))
      _raise(NeedGPS)
    end
    unless (bits >= 0)
      _raise(NoDeficitBits)
    end
    unless ((direction == LOW_END) || bounded?)
      _raise(UnboundedNonsense)
    end
    return dup if (bits == 0)

    value = @value
    mask = 2**bits - 1
    if (direction == HIGH_END)
      mask *= 2**@length if (bounded?)
    elsif (direction == LOW_END)
      value *= (2**bits)
    end
    value |= mask if (defval == 1)
    bounded? ? self.class.new(value, @length + bits) : self.class.new(value)
  end                           # def grow

  #
  # === Description
  #
  # As #grow, except that the current bitstring is changed rather
  # than a new one returned.
  #
  # Bits added are set to <i>defval</i> (default 0).
  #
  # :call-seq:
  # bitstring.grow!<i>(bits, [defval], [direction])</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>bits</i>] <i>Integer</i> Number of bits to add.
  # [<i>defval</i>] <i>Integer</i> Value to which added bits should be set.
  # [<i>direction</i>] Either <i>BitString::HIGH_END</i> (the default) or <i>BitString::LOW_END</i>.  Indicates whether bits are added at the least or most significant end.  Growing with <i>BitString::LOW_END</i> results in the bitstring being shifted left.
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] <i>bits</i> isn't an integer, <i>defval</i> can't be reduced to a binary value, or <i>direction</i> isn't one of the defined values.
  # [<tt>IndexError</tt>] <i>bits</i> is negative or meaningless.
  # [<tt>RuntimeError</tt>] Can't grow an unbounded string at the high end.
  #
  def grow!(bits=1, defval=0, direction=HIGH_END)
    bs = grow(bits, defval, direction)
    @length = bs.length if (bs.bounded?)
    @value = bs.to_i
    self
  end                           # def grow!

  #
  # === Description
  #
  # Return the length of the bitstring.  If it's bounded, the fixed size
  # is returned, otherwise the number of significant binary digits.
  #
  # :call-seq:
  # bitstring.length()
  #
  # === Arguments
  # <i>None</i>.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def length()
    @bounded ? @length : @value.to_s(2).length
  end                           # def length()

  #
  # === Description
  #
  # Return the value of the least significant (low) bit.
  #
  # :call-seq:
  # bitstring.lsb()
  #
  # === Arguments
  # <i>None</i>.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def lsb()
    self[0]
  end                           # def lsb()

  #
  # === Description
  #
  # Return the value of the most significant (high) bit.
  # Only meaningful for bounded bitstrings.
  #
  # :call-seq:
  # bitstring.msb()
  #
  # === Arguments
  # <i>None</i>.
  #
  # === Exceptions
  # [<tt>RuntimeError</tt>] There is no 'MSB' for an unbounded bitstring.
  #
  def msb()
    unless (@bounded)
      _raise(UnboundedNonsense,
             'most significant bit only applies to bounded bitstrings')
    end
    self[@length - 1]
  end                           # def msb()

  #
  # === Description
  #
  # Return a copy of the bitstring resized to the specified number of bits,
  # resulting in truncation or growth.  Bits are added to, or removed from,
  # the high (more significant) end.  Resizing an unbounded bitstring
  # makes it bounded.
  #
  # :call-seq:
  # bitstring.resize<i>(bits)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>bits</i>] Width of the resulting bitstring.
  #
  # === Exceptions
  # [<tt>IndexError</tt>] <i>bits</i> is negative or meaningless.
  #
  def resize(bits)
    unless (bits.kind_of?(Integer))
      _raise(BitsRInts)
    end
    unless (bits > 0)
      _raise(NoDeficitBits)
    end

    value = @value
    length = self.length
    bs = self.class.new(value, length)
    diffbits = bits - length
    diffbits < 0 ? bs.shrink!(-diffbits) : bs.grow!(diffbits)
  end                           # def resize

  #
  # === Description
  #
  # As #resize except it's the current bitstring that gets resized.
  #
  # :call-seq:
  # bitstring.resize!<i>(bits)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>bits</i>] Width of the resulting bitstring.
  #
  # === Exceptions
  # [<tt>IndexError</tt>] <i>bits</i> is negative or meaningless.
  #
  def resize!(bits)
    bs = resize(bits)
    @bounded = true
    @length = bs.length
    @value = bs.to_i
    self
  end                           # def resize!

  #
  # === Description
  #
  # Rotate the bitstring, taking bits from one end and shifting them
  # in at the other.  Only makes sense with bounded strings.
  #
  # A negative value rotates left; a positive one rotates to the right.
  #
  # :call-seq:
  # bistring.rotate<i>(bits)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>bits</i>] <i>Integer</i>.  Number of positions to rotate left (negative) or right (positive).  Bits rotated off one end are rotated in on the other.
  #
  # === Exceptions
  # [<i>RuntimeError</i>] Can't rotate an unbounded bitstring.
  #
  def rotate(bits_p)
    unless (bounded?)
      _raise(UnboundedNonsense,
             'rotation only applies to bounded bitstrings')
    end

    value = @value
    length = @length
    bits = bits_p.to_i.abs % length
    mask = (mult = 2**bits) - 1
    ldiff = length - bits
    if (bits_p > 0)
      #
      # Rotate right (toward the LSB)
      #
      residue = value & mask
      value /= mult
      value |= residue * 2**ldiff
    elsif (bits_p < 0)
      #
      # Rotate left (toward the MSB)
      #
      mask *= 2**ldiff
      residue = value & mask
      value = ((value & ~mask) * mult) | (residue / 2**ldiff)
    end
    self.class.new(value, @length)
  end                           # def rotate

  #
  # === Description
  #
  # Same as #rotate except that  the result is stored back into the
  # current object.
  #
  # :call-seq:
  # bitstring.rotate!<i>(bits)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>bits</i>] <i>Integer</i>.  Number of positions to rotate left (negative) or right (positive).  Bits rotated off one end are rotated in on the other.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def rotate!(bits_p)
    @value = rotate(bits_p).to_i
    self
  end                           # def rotate!

  #
  # === Description
  #
  # Shrink the bitstring (make it shorter) by truncating bits from
  # one end or the other.  Shrinking to fewer than 1 bits raises
  # an exception.
  #
  # :call-seq:
  # bitstring.shrink<i>(bits, [direction])</i>
  #
  # === Arguments
  # [<i>bits</i>]
  # [<i>direction</i>]
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] <i>bitcount</i> isn't an integer or <i>direction</i> isn't one of the defined values.
  # [<tt>IndexError</tt>] <i>bits</i> is negative or meaningless.
  #
  def shrink(bits=1, direction=HIGH_END)
    unless (bits.kind_of?(Integer))
      _raise(BitsRInts)
    end
    unless (bits >= 0)
      _raise(NoDeficitBits)
    end
    unless ([HIGH_END, LOW_END].include?(direction))
      _raise(NeedGPS)
    end
    return dup if (bits == 0)

    if (bounded? && (bits >= @length))
      _raise(RuntimeError, 'shrink count greater than bitstring size')
    end
    value = @value
    length = bounded? ? @length - bits : nil
    if (direction == LOW_END)
      value /= 2**bits
    else
      _raise(UnboundedNonsense) unless (bounded?)
      value &= 2**length - 1
    end
    bounded? ? self.class.new(value, length) : self.class.new(value)
  end                           # def shrink

  #
  # === Description
  #
  # As #shrink except that the current bitstring is modified rather than
  # a copy being made and altered.
  #
  # :call-seq:
  # bitstring.shrink!<i>(bits, [direction])</i>
  #
  # === Arguments
  # [<i>bits</i>]
  # [<i>direction</i>]
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] <i>bitcount</i> isn't an integer or <i>direction</i> isn't one of the defined values.
  # [<tt>IndexError</tt>] <i>bits</i> is negative or meaningless.
  #
  def shrink!(bits=1, direction=HIGH_END)
    bs = shrink(bits, direction)
    @length = bs.length if (bs.bounded?)
    @value = bs.to_i
    self
  end                           # def shrink!

  #
  # === Description
  #
  # Extract a subset from the bitstring.
  #
  # :call-seq:
  # bitstring.slice<i>(index)</i> => <i>Integer</i>
  # bitstring.slice<i>(start, length)</i> => <i>BitString</i>
  # bitstring.slice<i>(range)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>index</i>] <i>Integer</i>. Single bit position.
  # [<i>start</i>] <i>Integer</i>. Start position of subset.
  # [<i>length</i>] <i>Integer</i>. Length of subset.
  # [<i>range</i>] <i>Range</i>. Subset specified as a range.
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] If length specified with a range.
  # [<tt>IndexError</tt>] If bounded bitstring and substring is illegal.
  #
  def slice(*args_p)
    self[*args_p]
  end                           # def slice

  #
  # === Description
  #
  # :call-seq:
  #
  # === Arguments
  # [<i>*args_p</i>]
  #
  # === Exceptions
  #
  def slice!(*args_p)           # :nodoc:
    _raise(NotImplementError)
  end                           # def slice!

  #
  # === Description
  #
  # Return the full value of the bitstring represented as an integer.
  #
  # :call-seq:
  # bitstring.to_i<i>()</i> => <i>Integer</i>
  #
  # === Arguments
  # <i>None</i>.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def to_i()
    @value.to_i
  end                           # def to_i()

  #
  # === Description
  #
  # Return the bitlist as a <i>String</i> object consisting of '0' and '1'
  # characters.  If the bitstring is bounded, the <i>String</i> will
  # be zero-filled on the left (high end).
  #
  # :call-seq:
  # bitstring.to_s<i>()</i> => <i>String</i>
  #
  # === Arguments
  # <i>None</i>.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def to_s()
    _zfill(@value, @length)
  end                           # def to_s()

  #
  # List visibility alterations here, since the directive effects persist
  # past the next definition.
  #
  protected(:_zfill)

end                             # class BitString
