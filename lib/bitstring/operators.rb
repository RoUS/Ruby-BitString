#
# = operators.rb - Operators for the BitString class
#
# Author::    Ken Coar
# Copyright:: Copyright © 2010 Ken Coar
# License::   Apache Licence 2.0
#
# == Description
#
# Operator methods for <i>BitString</i> class (<i>e.g.</i>, those consisting
# of special characters).
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

#--
# @TODO items (or at least look at)
#
# Methods (unique to bitstrings):
#    &                # Bitwise AND
#    <                # Less-than
#    <<               # Shift left
#    <=               # Less-than or equal
#    >                # Greater-than
#    >=               # Greater-than or equal
#    >>               # Shift right
#    []               # Indexed access
#    []=              # Indexed setting
#    ^                # Bitwise XOR
#    |                # Bitwise inclusive OR
#    ~                # Bitwise NOT
#
# Methods (based on Array):
#    *                # Meaningless for bitstrings.
#    +                # Meaningless for bitstrings.
#    -                # Meaningless for bitstrings.
#    <=>              # Meaningless for bitstrings.
#
#++

#--
# Re-open the class to add the operator methods
#++

class BitString

  #
  # === Description
  #
  # Perform a bitwise AND on the entire bitstring, returning a new
  # <i>BitString</i> object.  The new bitstring will have the
  # same boundedness as the original.
  #
  # call-seq:
  # bitstring <i>& value</i> => <i>BitString</i>
  # bitstring.&<i>(value)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>value</i>] <i>BitString</i>, <i>Integer</i>, or <i>String</i>.  Value to AND with the bitstring.
  #
  # === Examples
  #   bs = BitString.new('111111111')
  #   nbs = bs & '111100011'
  #   puts nbs.to_s.inspect
  #   "111100011"
  #
  # === Exceptions
  # <i>None</i>.
  #
  def &(val)
    val = _arg2int(val)
    vMask = self.mask
    newval = (@value & val) & vMask
    bounded? ? self.class.new(newval, @length) : self.class.new(newval)
  end                           # def &

  #
  # === Description
  #
  # Perform a left-shift on the bitstring, returning a <i>BitString</i>
  # containing the shifted value.  If the bitstring is bounded, bits
  # shifted off the high end are lost.
  #
  # call-seq:
  # bitstring <i>&lt;&lt; bitcount</i> => <i>BitString</i>
  # bitstring.&lt;&lt;<i>(bitcount)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>bitcount</i>] <i>Integer</i>.  Number of positions by which to left-shift.
  #
  # === Examples
  #
  # === Exceptions
  # <i>None</i>.
  #
  def <<(bits)
    value = @value * (2**bits.to_i)
    if (bounded?)
      self.class.new(value & self.mask, @length)
    else
      self.class.new(value)
    end
  end                           # def <<

  #
  # === Description
  #
  # Right-shift the bitstring (toward the low end) by the specified number
  # of bits.  Bits shifted off the end are lost; new bits shifted in at
  # the high end are 0.
  #
  # call-seq:
  # bitstring &gt;&gt; <i>bitcount</i> => <i>BitString</i>
  # bitstring.&gt;&gt;<i>(bitcount)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>bitcount</i>] <i>Integer</i>.  Number of positions to right-shift by.
  #
  # === Examples
  #
  # === Exceptions
  # <i>None</i>.
  #
  def >>(bits)
    value = @value / 2**bits.to_i
    if (bounded?)
      self.class.new(value, @length)
    else
      self.class.new(value)
    end
  end                           # def >>

  #
  # === Description
  #
  # Extract a particular substring from the bitstring.
  # If we're given a single index, we return an integer; if
  # a range, we return a new BitString.
  #
  # call-seq:
  # bitstring<i>[index]</i> => <i>Integer</i>
  # bitstring<i>[start, length]</i> => <i>BitString</i>
  # bitstring<i>[range]</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>index</i>] <i>Integer</i>. Single bit position.
  # [<i>start</i>] <i>Integer</i>. Start position of subset.
  # [<i>length</i>] <i>Integer</i>. Length of subset.
  # [<i>range</i>] <i>Range</i>. Subset specified as a range.
  #
  # === Examples
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] If length specified with a range.
  # [<tt>IndexError</tt>] If bitstring is bounded and the substring is illegal.
  #
  def [](pos_p, length_p=nil)
    #
    # Turn a position/length into a range.
    #
    if (pos_p.kind_of?(Integer) && length_p.kind_of?(Integer))
      pos_p = Range.new(pos_p, pos_p + length_p - 1)
      length_p = nil
    end
    if (pos_p.kind_of?(Range))
      unless (length_p.nil?)
        raise ArgumentError.new('length not allowed with range')
      end
      pos_a = pos_p.to_a
      pos_a.reverse! if (pos_a.first < pos_a.last)
      r = pos_a.collect { |pos| self[pos].to_s }
      return self.class.new(r.join(''), r.length)
    end
    pos = pos_p.to_i
    #
    # Blow an error if we were given an index out of range.
    #
    unless ((pos >= 0) &&
            ((! bounded?) || pos.between?(0, @length - 1)))
      _raise(OuttasightIndex, pos)
    end
    (@value & (2**pos)) / (2**pos)
  end                           # def []

  #
  # === Description
  #
  # Set a bit or range of bits with a single operation.
  #
  # call-seq:
  # bitstring[<i>pos</i>] = <i>value</i>   => <i>value</i>
  # bitstring[<i>start, length</i>] = <i>value</i>   => <i>value</i>
  # bitstring[<i>range</i>] = <i>value</i>   => <i>value</i>
  #
  # === Arguments
  # [<i>value</i>] <i>Array</i>, <i>BitString</i>, <i>Integer</i>, or <i>String</i>. Value (treated as a stream of bits) used to set the bitstring.
  # [<i>pos</i>] <i>Integer</i>.  Single bit position to alter.
  # [<i>start</i>] <i>Integer</i>.  First bit position in substring.
  # [<i>length</i>] <i>Integer</i>.  Number of bits in substring.
  # [<i>range</i>] <i>Range</i>.  Range of bits (<i>e.g.</i>, 5..10) to affect.
  #
  # === Examples
  #
  # === Exceptions
  # [<tt>ArgumentError</tt>] Both range and length specified, or value cannot be interpreted as an integer.
  # [<tt>IndexError</tt>] Non-integer or negative index, or beyond the end of the bitstring.
  #
  def []=(*args_p)
    low = high = width = nil
    args = args_p
    if (args.length == 2)
      #
      # [pos]= or [range]=
      #
      if ((r = args[0]).class.eql?(Range))
        #
        # Convert into a [start,length] format to reuse that stream.
        #
        (start, stop) = [r.first, r.last].sort
        width = stop - start + 1
        args = [start, width, args[1]]
      else
        args = [args[0], 1, args[1]]
      end
    elsif (args_p.length != 3)
      _raise(WrongNargs, args_p.length, 3)
    end
    #
    # Special cases of args have now been normalised to [start,length,value].
    # Make sure the values are acceptable.
    #
    (start, nBits, value) = args
    _raise(BogoIndex, start) unless (start.respond_to?(:to_i))
    start = start.to_i unless (start.kind_of?(Integer))
    _raise(BogoIndex, nBits) unless (nBits.respond_to?(:to_i))
    nBits = length.to_i unless (nBits.kind_of?(Integer))
    highpos = start + nBits - 1
    _raise(OuttasightIndex, highpos) if (bounded? && (highpos > @length - 1))
    _raise(BitsRInts, value) unless (value.respond_to?(:to_i))
    value = _arg2int(value)
    #
    # All the checking is done, let's do this thing.
    #
    vMask = 2**nBits - 1
    value &= vMask
    vMask *= 2**start
    value *= 2**start

    highpos = self.length
    bValue = @value & ((2**highpos - 1) & ~vMask)
    @value = bValue | value
    value / 2**start
  end                           # def []=

  #
  # === Description
  #
  # Perform a bitwise exclusive OR (XOR) and return a copy of the
  # result.
  #
  # call-seq:
  # bitstring <i>^ value</i> => <i>BitString</i>
  # bitstring.^<i>(value)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>value</i>] <i>Array</i>, <i>BitString</i>, <i>Integer</i>, or <i>String</i>.  Value treated as a bitstream and exclusively ORed with the bitstring.
  #
  # === Examples
  #
  # === Exceptions
  # <i>None</i>.
  #
  def ^(value)
    value = _arg2int(value)
    value &= self.mask if (bounded?)
    bs = dup
    bs.from_i(value ^ bs.to_i)
    bs
  end                           # def ^

  #
  # === Description
  #
  # Perform a bitwise inclusive OR with the current bitstring and
  # return a bitstring containing the result.
  #
  # call-seq:
  # bitstring <i>| value</i> => <i>BitString</i>
  # bitstring.|<i>(value)</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>value</i>] <i>Array</i>, <i>BitString</i>, <i>Integer</i>, or <i>String</i>.  Value treated as a bitstream and inclusively ORed with the bitstring.
  #
  # === Examples
  #
  # === Exceptions
  # <i>None</i>.
  #
  def |(value)
    value = _arg2int(value)
    value &= self.mask if (bounded?)
    bs = dup
    bs.from_i(value | bs.to_i)
    bs
  end                           # def |

  #
  # === Description
  #
  # Perform a one's complement on the current bitstring and return the
  # result in a new one.
  #
  # call-seq:
  # <i>~</i> bitstring => <i>BitString</i>
  # bitstring.~<i>()</i> => <i>BitString</i>
  #
  # === Arguments
  # <i>None</i>.
  #
  # === Examples
  #
  # === Exceptions
  # <i>None</i>.
  #
  def ~()
    newval = (~ @value) & self.mask
    bounded? ? self.class.new(newval, @length) : self.class.new(newval)
  end                           # def ~

  #
  # === Description
  #
  # Perform an equality check against another bitstring.
  #
  # call-seq:
  # bitstring == <i>compstring</i> => <i>Boolean</i>
  # bitstring.==<i>(compstring)</i> => <i>Boolean</i>
  #
  # === Arguments
  # [<i>compstring</i>] <i>BitString</i>. Bitstring to compare against.
  #
  # === Examples
  #
  # === Exceptions
  # <i>None</i>.
  #
  def ==(value)
    (self.class == value.class) &&
      (self.bounded? == value.bounded?) &&
      (@value == value.to_i)
  end                           # def ==

end                             # class BitString
