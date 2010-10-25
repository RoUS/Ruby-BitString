# -*- coding: utf-8 -*-
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
# Bug/feature trackers, code, and mailing lists are available at
# http://rubyforge.org/projects/bitstring.
#
# Class and method documentation is online at
# http://bitstring.rubyforge.org/rdoc/
#
# == Description
#
# The <i>BitString</i> package provides a class for handling a series
# of bits as an array-like structure.  Bits are addressable individually
# or as subranges.
#
# BitString objects can be either bounded or unbounded.  Bounded bitstrings
# have a specific number of bits, and operations that would affect bits
# outside those limits will raise exceptions.  Unbounded bitstrings can
# grow to arbitrary lengths, but some operations (like rotation) cannot
# be performed on them.
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

#
# It's sort of like a fake a subclass of Integer solely to
# differentiate bitstrings.
#
class BitString

  #
  # Versionomy object for the class, recording the current version.
  #
  Version = Versionomy.parse('1.0.0')

  #
  # Version number as a simple readable string.
  #
  VERSION = Version.to_s

  #
  # Other constants:
  #

  #
  # Identifer specifying the least significant (low) end of the bitstring
  # (used by <i>grow</i>, <i>shrink</i>, and <i>mask</i>).
  #
  LOW_END = :low
  #
  # Identifer specifying the most significant (high) end of the bitstring
  # (used by <i>grow</i>, <i>shrink</i>, and <i>mask</i>).
  #
  HIGH_END = :high

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
  # (.zip makes sense, but I'm going to defer it until I have a test for it.)
  #
  undef :grep, :sort, :sort_by, :zip

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
  # new<i>([val], [bitcount])</i> => <i>BitString</i>
  # new<i>(length) {|index| block }</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>val</i>] <i>Array</i>, <i>Integer</i>, <i>String</i>, or <i>BitString</i>. Initial value for the bitstring.  If a <i>String</i>, the value must contain only '0' and '1' characters; if an <i>Array</i>, all elements must be 0 or 1.  Default 0.
  # [<i>bitcount</i>] <i>Integer</i>.  Optional length (number of bits) for a bounded bitstring.
  #
  # === Examples
  #  bs = BitString.new(4095)
  #  bs.to_s
  #  => "111111111111"
  #  bs.bounded?
  #  => false
  #
  #  bs = BitString.new('110000010111', 12)
  #  bs.bounded?
  #  => true
  #  bs.to_i
  #  => 3095
  #
  #  bs = BitString.new(12) { |pos| pos % 2 }
  #  bs.to_s
  #  => "101010101010"
  #
  # === Exceptions
  # [<tt>RangeError</tt>] <i>val</i> is a string, but contains non-binary digits.
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
      @value = _arg2int(val)
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
  # Convert a value from some representation into an integer.  Possibly
  # acceptable inputs are:
  #
  # o An <i>Array</i> containing only 0 and 1 values.
  # o An existing <i>BitString</i> object
  # o An <i>Integer</i> or descendent binary value
  # o A <i>String</i> containing only '0' and '1' characters
  #
  # Any other inputs will raise an exception.
  #
  # :call-seq:
  # _arg2int<i>(value)</i> => <i>Integer</i>
  #
  # === Arguments
  # [<i>value</i>] <i>Array</i>, <i>BitString</i>, <i>Integer</i>, <i>String</i>.  The value to be converted to an integer.
  # [<i>msg</i>] <i>String</i>.  Message to use if we don't have a canned one.
  #
  # === Examples
  #  _arg2int(23)
  #  => 23
  #  _arg2int('110000010111')
  #  => 3095
  #  _arg2int([1,1,0,0,0,0,0,1,0,1,1,1])
  #  => 3095
  #  _arg2int('alpha')
  #  => exception: "ArgumentError: value ('alpha':String) contains invalid digits"
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] Can't reduce the argument to a binary integer.
  #
  def _arg2int(val_p)           # :nodoc:
    if (val_p.class.eql?(BitString))
      #
      # If we were passed a bitstring, convert it.
      #
      val = val_p.to_i
    elsif (val_p.class.eql?(String))
      #
      # If we were given a String for the value, it must consist of valid
      # binary digits.
      #
      _raise(BadDigit, nil, val_p) unless (val_p.gsub(/[01]/, '').empty?)
      val = val_p.to_i(2)
    elsif (val_p.class.eql?(Array))
      #
      # If we were given an array, make sure that all the values are
      # integers and either 1 or 0.
      #
      _raise(BadDigit, nil, val_p) unless ((val_p - [0, 1]).empty?)
      val = val_p.collect { |bit| bit.to_s(2) }.join('').to_i(2)
    elsif (val_p.kind_of?(Integer))
      val = val_p
    else
      #
      # Let's try to convert it to an integer from whatever class we
      # were passed.
      #
      unless (val_p.respond_to?(:to_i))
        raise ArgumentError.new('unable to determine bitstring value from ' +
                                "\"#{val_p.to_s}\":#{val_p.class.name}")
      end
    end
    val
  end                           # def _arg2int

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
  # === Examples
  #  _raise(BadDigit, nil, bogusvalue)
  #  _raise(OuttasightIndex, 'you are kidding, right?')
  #
  # === Exceptions
  # [<tt>InternalError</tt>] Called with something other than an exception.
  # [<i>other</I>] As indicated.
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
        args = []
      elsif (args[0].kind_of?(String))
        msg = args.shift
      else
        msg = nil
      end

      mName = e.backtrace[1].match(/in \`(\S*)'/).captures[0]
      case exc.name.sub(/^.*::/, '')
      when 'BadDigit'
        if (msg.nil?)
          val = args[1].respond_to?(:to_s) ? args[1].to_s : args[1].inspect
          msg = "value ('#{val}':#{args[1].class.name}) contains invalid digits"
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
  # or left-truncated to the specified length.
  #
  # :call-seq:
  # _zfill<i>(value, length)</i> => <i>String</i>
  #
  # === Arguments
  # [<i>val</i>] <i>Integer</i> or <i>String</i>.  Value to be represented as a string of binary digits.
  # [<i>length</i>] <i>Integer</i>. Length of output string to return.
  #
  # === Examples
  #  _zfill(0, 12)
  #  => "000000000000"
  #
  #  _zfill(3095, 4)
  #  => "0111"
  #
  #  _zfill(3095, 15)
  #  => "000110000010111"
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
  # === Examples
  #  bs = BitString.new(3095)
  #  bs.bounded?
  #  => false
  #
  #  bs = BitString.new(3095, 12)
  #  bs.bounded?
  #  => true
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
  # <i>None</i>.
  #
  # === Examples
  #  bs = BitString.new(3095)
  #  nbs = bs.clear
  #  bs.to_s
  #  => "110000010111"
  #  nbs.to_s
  #  => "0"
  #
  # === Exceptions
  # <i>None</i>.
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
  # <i>None</i>.
  #
  # === Examples
  #  bs = BitString.new(3095, 12)
  #  bs.to_s
  #  => "110000010111"
  #  bs.clear!
  #  bs.to_s
  #  => "000000000000"
  #
  # === Exceptions
  # <i>None</i>.
  #
  def clear!()
    @value = 0
    self
  end                           # def clear!()

  #
  # === Description
  #
  # Execute a block for each bit in the bitstring.
  #
  # :call-seq:
  # bitstring.<i>each</i> { |<i>bitval</i>| <i>block</i> } => <i>BitString</i>
  #
  # === Arguments
  # [<i>block</i>] <i>Proc</i>. Block to be called for each bit in the string.  The block is passed the bit value.
  #
  # === Examples
  #  bs = BitString.new('100101')
  #  bs.each { |bitval| puts bitval }
  #  1
  #  0
  #  1
  #  0
  #  0
  #  1
  #
  # === Exceptions
  # <i>None</i>.
  #
  def each(&block)
    self.length.times { |bit| block.call(self[bit]) }
    self
  end                           # def each

  #
  # === Description
  #
  # Return true if there are no bits set in the bitstring.
  #
  # :call-seq:
  # bitstring.<i>empty?</i>
  #
  # === Arguments
  # <i>None</i>.
  #
  # === Examples
  #  bs = BitString.new('100101')
  #  bs.empty?
  #  => false
  #
  #  bs = BitString.new('000000')
  #  bs.empty?
  #  => true
  #
  # === Exceptions
  # <i>None</i>.
  #
  def empty?()
    @value.eql?(0)
  end                           # def empty?

  #
  # === Description
  #
  # Treat the bitstring as an Integer and store its entire value at
  # once.
  #
  # :call-seq:
  # bitstring.from_i<i>(newval)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>newval</i>] <i>Integer</i>. Value from which bits will be copied to the bitstring.
  #
  # === Examples
  #  bs = BitString.new(0, 12)
  #  bs.to_s
  #  => "000000000000"
  #  bs.from_i(3095)
  #  bs.to_s
  #  => "110000010111"
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
    self
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
  # [<i>bits</i>] <i>Integer</i>. Number of bits to add.
  # [<i>defval</i>] <i>Integer</i>. Value to which added bits should be set.
  # [<i>direction</i>] <i>Constant</i>. Either <tt>BitString::HIGH_END</tt> (the default) or <tt>BitString::LOW_END</t>.  Indicates whether bits are added at the least or most significant end.  Growing with <tt>BitString::LOW_END</tt> results in the bitstring being shifted left.
  #
  # === Examples
  #  bs = BitString(5, 3)
  #  bs.to_s
  #  => "101"
  #  nbs = bs.grow(3)
  #  nbs.to_s
  #  => "000101"
  #  nbs = bs.grow(3, 1)
  #  nbs.to_s
  #  => "111101"
  #  nbs = bs.grow(3, 0, BitString::LOW_END)
  #  nbs.to_s
  #  => "101000"
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
    vMask = 2**bits - 1
    if (direction == HIGH_END)
      vMask *= 2**@length if (bounded?)
    elsif (direction == LOW_END)
      value *= (2**bits)
    end
    value |= vMask if (defval == 1)
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
  # [<i>direction</i>] <i>Constant</i>. Either <tt>BitString::HIGH_END</tt> (the default) or <tt>BitString::LOW_END</tt>.  Indicates whether bits are added at the least or most significant end.  Growing with <tt>BitString::LOW_END</tt> results in the bitstring being shifted left.
  #
  # === Examples
  #  bs = BitString.new(5, 3)
  #  bs.to_s
  #  => "101"
  #  bs.grow!(3)
  #  bs.to_s
  #  => "000101"
  #  bs.grow!(3, 1, BitString::LOW_END)
  #  bs.to_s
  #  => "000101111"
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
  # === Examples
  #  bs = BitString.new('101', 3)
  #  bs.length
  #  => 3
  #
  #  bs = BitString.new('00101', 5)
  #  bs.length
  #  => 5
  #
  #  bs = BitString.new('00101')
  #  bs.length
  #  => 3
  #
  # === Exceptions
  # <i>None</i>.
  #
  def length()
    bounded? ? @length : @value.to_s(2).length
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
  # === Examples
  #  bs = BitString.new('101')
  #  bs.lsb
  #  => 1
  #
  #  bs = BitString.new('010')
  #  bs.lsb
  #  => 0
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
  # Return an integer with bits set to mask the specified portion of the
  # bitstring.
  #
  # If you want to create a mask wider than the bitstring, use the class
  # method <i>BitString.mask()</i> instead.
  #
  # :call-seq:
  # bitstring.mask<i>([bitcount], [direction])</i> => <i>Integer</i>
  #
  # === Arguments
  # [<i>bitcount</i>] <i>Integer</i>.  Number of bits to set in the mask.
  # [<i>direction</i>] <i>Constant</i>. <tt>BitString::HIGH_END</tt> (the default) or <tt>BitString::LOW_END</tt>.  Specifies the end of the bitstring from which the mask starts.
  #
  # === Examples
  #  bs = BitString.new(0, 12)
  #  bs.mask.to_s(2)
  #  => "111111111111"
  #  bs.mask(5).to_s(2)
  #  => "111110000000"
  #  bs.mask(5, BitString::LOW_END).to_s(2)
  #  => "11111"
  #  BitString.new(bs.mask(5, BitString::LOW_END), 12).to_s
  #  => "000000011111"
  #
  # === Exceptions
  # [<tt>IndexError</tt>] Raised if <i>bitcount</i> is negative or grater than the bitstring length.
  #
  def mask(bits=self.length, direction=HIGH_END)
    _raise(OuttasightIndex, bits) if (bits > self.length)
    _raise(NoDeficitBits) if (bits < 0)
    vMask = 2**bits - 1
    vMask *= 2**(self.length - bits) if (direction == HIGH_END)
    vMask
  end                           # def mask()

  #
  # === Description
  #
  # Class method to return an integer value with the specified number
  # of bits (starting at position 0) all set to 1.
  #
  # :call-seq:
  # BitString.mask<i>(bitcount)</i> => <i>Integer</i>
  #
  # === Arguments
  # [<i>bitcount</i>] <i>Integer</i>.  Number of bits to set in the mask.
  #
  # === Examples
  #  BitString.mask(5).to_s(2)
  #  => "11111"
  #
  # === Exceptions
  # <i>None</i>.
  #
  def self.mask(bits=1)
    new._raise(NoDeficitBits) if (bits < 0)
    vMask = 2**bits - 1
  end                           # def self.mask

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
  # === Examples
  #  bs = BitString.new('0101')
  #  bs.msb
  #  => 1                      # Leading zeroes stripped in unbouded bitstrings
  #
  #  bs = BitString.new('0101', 4)
  #  bs.msb
  #  => 0
  #
  # === Exceptions
  # [<tt>RuntimeError</tt>] There is no 'MSB' for an unbounded bitstring.
  #
  def msb()
    unless (bounded?)
      _raise(UnboundedNonsense,
             'most significant bit only applies to bounded bitstrings')
    end
    self[@length - 1]
  end                           # def msb()

  #
  # === Description
  #
  # Return the number of bits in the bitstring that are either set (1)
  # or clear (0).  Leading zeroes on unbounded bitstrings are ignored.
  #
  # :call-seq:
  # bitstring.population<i>(testval)</i> => <i>Integer</i>
  #
  # === Arguments
  # [<i>testval</i>] <i>Array</i>, <i>BitString</i>, <i>Integer</i>, or <i>String</i> whose low bit is used for the test.
  #
  # === Examples
  #  bs = BitString.new('0001111001010')
  #  bs.population(0)
  #  => 4
  #  bs.population(1)
  #  => 6
  #
  #  bs = BitString.new('0001111001010', 13)
  #  bs.population(0)
  #  => 7
  #  bs.population(1)
  #  => 6
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] The argument cannot be reduced to a binary digit.
  #
  def population(val)
    val = _arg2int(val) & 1
    self.select { |bval| bval == val }.length
  end                           # def population

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
  # === Examples
  #  bs = BitString.new('101')
  #  bs.bounded?
  #  => false
  #  nbs = bs.resize(5)
  #  nbs.bounded?
  #  => true
  #  nbs.length
  #  => 5
  #  nbs.to_s
  #  => "00101"
  #  nbs = bs.resize(7)
  #  nbs.to_s
  #  => "0000101"
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
  # === Examples
  #  bs = BitString.new('101')
  #  bs.bounded?
  #  => false
  #  bs.resize!(5)
  #  bs.bounded?
  #  => true
  #  bs.length
  #  => 5
  #  bs.to_s
  #  => "00101"
  #  bs.resize!(7)
  #  bs.to_s
  #  => "0000101"
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
  # === Examples
  #  bs = BitString.new('000000011111', 12)
  #  bs.rotate(3).to_s
  #  => "000011111000"
  #  bs.rotate(-4).to_s
  #  => "100000001111"
  #
  # === Exceptions
  # [<tt>RuntimeError</tt>] Can't rotate an unbounded bitstring.
  #
  def rotate(bits_p)
    unless (bounded?)
      _raise(UnboundedNonsense,
             'rotation only applies to bounded bitstrings')
    end

    value = @value
    length = @length
    bits = bits_p.to_i.abs % length
    vMask = (mult = 2**bits) - 1
    ldiff = length - bits
    if (bits_p > 0)
      #
      # Rotate right (toward the LSB)
      #
      residue = value & vMask
      value /= mult
      value |= residue * 2**ldiff
    elsif (bits_p < 0)
      #
      # Rotate left (toward the MSB)
      #
      vMask *= 2**ldiff
      residue = value & vMask
      value = ((value & ~vMask) * mult) | (residue / 2**ldiff)
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
  # === Examples
  #  bs = BitString.new('000000011111', 12)
  #  bs.rotate!(3)
  #  bs.to_s
  #  => "000011111000"
  #  bs.rotate!(-4)
  #  bs.to_s
  #  => "100000001111"
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
  # Iterate through all the bits, invoking the specified block with the
  # value of each in turn.  If the block returns a true value, the
  # bit value is added to the result array.
  #
  # :call-seq:
  # bitstring.select { <i>|bit| block</i> } => <i>Array</i>
  #
  # === Arguments
  # [<i>bit</i>] <i>Integer</i>.  The value (0 or 1) of the current bit.
  # [<i>block</i>] <i>Proc</i>.  The block of code to execute.
  #
  # === Examples
  #  bs = BitString.new('11001110001')
  #  bs.select { |bit| bit == 1}
  #  => [1, 1, 1, 1, 1, 1]
  #
  #  bs = BitString.new('0011001110001')
  #  bs.select { |bit| bit == 0}
  #  => [0, 0, 0, 0, 0]      # because unbounded leadings zeroes are dropped
  # 
  #  bs = BitString.new('0011001110001', 13)
  #  bs.select { |bit| bit == 0}
  #  => [0, 0, 0, 0, 0, 0, 0]
  # 
  # === Exceptions
  # <i>None</i>.
  #
  def select(&block)
    result = []
    self.each do |val|
      result.push(val) if (block.call(val))
    end
    result
  end                           # def select

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
  # [<i>bits</i>]  <i>Integer</i>.  Number of bits to truncate.
  # [<i>direction</i>]  <i>Constant</i>.  Either <tt>BitString::HIGH_END</tt> (the default) or <tt>BitString::LOW_END</tt>.
  #
  # === Examples
  #  bs = BitString.new(3095)      # 110000010111
  #  nbs = bs.shrink(5)
  #  nbs.to_s
  #  => "10111"                    # Unbounded leading zeroes aren't significant
  #  nbs = nbs.shrink(2, BitString::LOW_END)
  #  nbs.to_s
  #  => "101"
  #
  #  bs = BitString.new(3095, 12)  # 110000010111
  #  nbs = bs.shrink(5)
  #  nbs.to_s
  #  => "0010111"
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
  # [<i>bits</i>]  <i>Integer</i>.  Number of bits to truncate.
  # [<i>direction</i>]  <i>Constant</i>.  <tt>BitString::HIGH_END</tt> (the default) or <tt>BitString::LOW_END</tt>.
  #
  # === Examples
  #  bs = BitString.new(3095)      # 110000010111
  #  bs.shrink!(5)
  #  bs.to_s
  #  => "10111"                    # Unbounded leading zeroes aren't significant
  #  bs.shrink!(2, BitString::LOW_END)
  #  bs.to_s
  #  => "101"
  #
  #  bs = BitString.new(3095, 12)  # 110000010111
  #  bs.shrink!(5)
  #  bs.to_s
  #  => "0010111"
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
  # Extract a subset from the bitstring.  See the description of
  # the <tt>[]</tt> method.
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
  def slice(*args)
    self[*args]
  end                           # def slice

  #
  # === Description
  #
  # Select the specified bits from the bitstring, and remake it using
  # only those bits.  If bounded, the size will be adjusted to match
  # the number of bits selected.  This is an alternative way to change
  # the size and value of an existing bitstring (see the grow!(), shrink!(),
  # and resize!() methods.)
  #
  # :call-seq:
  # bitstring.slice!<i>(index)</i> => <i>Integer</i>
  # bitstring.slice!<i>(start, length)</i> => <i>BitString</i>
  # bitstring.slice!<i>(range)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>index</i>] <i>Integer</i>. Single bit position.
  # [<i>start</i>] <i>Integer</i>. Start position of subset.
  # [<i>length</i>] <i>Integer</i>. Length of subset.
  # [<i>range</i>] <i>Range</i>. Subset specified as a range.
  #
  # === Examples
  #  bs = BitString.new(3095, 12)
  #  bs.to_s
  #  => "110000010111"
  #  bs.slice!(4..10)
  #  bs.to_s
  #  => "1000001"
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] If length specified with a range.
  # [<tt>IndexError</tt>] If bounded bitstring and substring is illegal.
  #
  def slice!(*args)
    bs = self[*args]
    @value = bs.to_i
    @bounded = bs.bounded?
    @length = bs.length if (bs.bounded?)
    self
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
  # === Examples
  #  bs = BitString.new('110000010111')
  #  bs.to_i
  #  => 3095
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
  # === Examples
  #  bs = BitString.new(3095)
  #  bs.to_s
  #  => "110000010111"
  #
  #  bs = BitString.new(3095, 14)
  #  bs.to_s
  #  => "00110000010111"
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
  protected(:_arg2int, :_raise, :_zfill)

end                             # class BitString
