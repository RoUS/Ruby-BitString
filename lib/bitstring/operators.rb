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
#  Add 'foo[start,count] = val'
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
  # call-seq:
  # new<i>([value], [length], [bounded])</i> => _BitString_
  #
  # === Arguments
  # [<i>val_p</i>]
  #
  # === Exceptions
  # _None_.
  #
  def &(val_p)
    @value < val_p
  end                           # def &

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
  def <(val_p)
    @value < val_p
  end                           # def <

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
  def <<(val_p)
    @value = @value * (2**val_p)
  end                           # def <<

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
  def <=(val_p)
    @value <= val_p
  end                           # def <=

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
  def >(val_p)
    @value > val_p
  end                           # def >

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
  def >=(val_p)
    @value >= val_p
  end                           # def >=

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
  def >>(val_p)
    @value = @value / (2**val_p)
    @value = @value.to_int if (@value.respond_to?('to_int'))
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
      return self.class.new(r.join(''))
    end
    pos = pos_p.to_i
    #
    # Blow an error if we were given an index out of range.
    #
    unless ((pos >= 0) &&
            ((! @bounded) || pos.between?(0, @length - 1)))
      _raise(OuttasightIndex, pos)
    end
    (@value & (2**pos)) / (2**pos)
  end                           # def []

  #
  # === Description
  #
  # call-seq:
  # new<i>([value], [length], [bounded])</i> => _BitString_
  #
  # === Arguments
  # [<i>pos_p</i>]
  # [<i>val_p</i>]
  #
  # === Exceptions
  # [<tt>IndexError</tt>]
  # [<tt>RangeError</tt>]
  #
  def []=(pos_p, val_p)
    if (pos_p.class.eql?(Range))
      vals = _zfill(val_p, pos_p.last - pos_p.first + 1).split(//)
      pos_p.to_a.each { |i| self[i] = vals.shift }
      return val_p
    end
    pos = pos_p.to_i
    val = val_p.to_i
    unless ((! @bounded) || pos.between?(0, @length - 1))
      _raise(OuttasightIndex, pos)
    end
    unless ([0, 1].include?(val.to_i))
      _raise(BadDigit)
    end
    @value = (@value & ((~ (2**pos))) | ((val.to_i & 1) * (2**pos)))
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
  # new<i>([value], [length], [bounded])</i> => _BitString_
  #
  # === Arguments
  # [<i>val_p</i>]
  #
  # === Exceptions
  # _None_.
  #
  def ~(val_p)
    @value < val_p
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
