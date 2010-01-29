#
# = bitstring.rb - Bounded and unbounded bit strings
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
# Copyright © 2009 Ken Coar
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
#  Add 'foo[start,count] = val' (FREQ #27742)
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

#
# Re-open the class to add the operator methods
#
class BitString

  #
  # === Description
  #
  # Perform a bitwise AND on the entire bitstring, returning a new
  # <i>BitString</i> object.
  #
  # call-seq:
  # <i>bitstring & value</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>val</i>] <i>Integer</i>.  Value to AND with the bitstring.
  #
  # === Exceptions
  # _None_.
  #
  def &(val)
    mask = 2**self.length - 1
    newval = (@value & val.to_i) & mask
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
  # <i>bitstring << bitcount</i> => <i>BitString</i>
  #
  # === Arguments
  # [<i>bitcount</i>] <i>Integer</i>.  Number of positions to left-shift by.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def <<(bits)
    value = @value * (2**bits.to_i)
    if (bounded?)
      mask = 2**@length - 1
      self.class.new(value & mask, @length)
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
  # <i>bitstring >> bitcount</i> => _BitString_
  #
  # === Arguments
  # [<i>bitcount</i>] <i>Integer</i>.  Number of positions to right-shift by.
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
  # === Exceptions
  # [<tt>ArgumentError</tt>] If length specified with a range.
  # [<tt>IndexError</tt>] If bounded bitstring and substring is illegal.
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
  # bitstring[<i>range</i> = <i>value</i>   => <i>value</i>
  #
  # === Arguments
  # [<i>value</i>] <i>Integer</i>.
  # [<i>pos</i>] <i>Integer</i>.
  # [<i>start</i>] <i>Integer</i>.
  # [<i>length</i>] <i>Integer</i>.
  # [<i>range</i>] <i>Range</i>.
  #
  # === Exceptions
  # [<tt>IndexError</tt>]
  # [<tt>RangeError</tt>]
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
    value = value.to_i unless (value.kind_of?(Integer))
    #
    # All the checking is done, let's do this thing.
    #
    mask = 2**nBits - 1
    value &= mask
    mask *= 2**start
    value *= 2**start

    highpos = self.length
    bValue = @value & ((2**highpos - 1) & ~mask)
    @value = bValue | value
    value / 2**start
  end                           # def []=

  #
  # === Description
  #
  # call-seq:
  # new<i>([value], [length], [bounded])</i> => _BitString_
  #
  # === Arguments
  # [<i>val_p</i>]
  #
  # === Exceptions
  # _None_.
  #
  def ^(val_p)
    @value < val_p
  end                           # def ^

  #
  # === Description
  #
  # call-seq:
  # new<i>([value], [length], [bounded])</i> => _BitString_
  #
  # === Arguments
  # [<i>val_p</i>]
  #
  # === Exceptions
  # _None_.
  #
  def |(val_p)
    @value < val_p
  end                           # def |

  #
  # === Description
  #
  # call-seq:
  # ~ <i>bitstring</i> => _BitString_
  #
  # === Arguments
  # <i>None</i>.
  #
  # === Exceptions
  # <i>None</i>.
  #
  def ~()
    mask = 2**self.length - 1
    newval = (~ @value) & mask
    bounded? ? self.class.new(newval, @length) : self.class.new(newval)
  end                           # def ~

  #
  # === Description
  #
  # call-seq:
  # new<i>([value], [length], [bounded])</i> => _BitString_
  #
  # === Arguments
  # [<i>val_p</i>]
  #
  # === Exceptions
  # _None_.
  #
  def ==(val_p)
    @value == val_p
  end                           # def ==

end                             # class BitString
