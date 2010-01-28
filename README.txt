BitString - 'Arrays' of bits for Ruby
=====================================

* http://rubyforge.org/projects/bitstring/

DESCRIPTION:
------------

BitString is a Ruby class for providing access to lists of bits in
an 'Array'-like manner.  Direct addressing, subranging, masking,
e cetera.


FEATURES:
---------

* Many of the features of the Array class are available for BitString.


PROBLEMS:
---------

* None known.


SYNOPSIS:
---------

  require 'bitstring'
  bs = BitString.new('100101001')
  bs = BitString.new('100101001', 9)

REQUIREMENTS:
-------------

* Gem 'versionomy'


INSTALL:
--------

BitString is installed using the canonical method:

  sudo gem install bitstring


LICENSE:
--------

Copyright © 2010 Ken Coar

Licensed under the Apache License, Version 2.0 (the "License"); you
may not use this file except in compliance with the License. You may
obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
implied. See the License for the specific language governing
permissions and limitations under the License.
