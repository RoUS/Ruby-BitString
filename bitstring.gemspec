require 'lib/bitstring'

# rdoc_options=[]
# specification_version=3
# new_platform="ruby"
# loaded=false
# autorequire=nil
# email=nil
# required_ruby_version=#<Gem::Requirement:0xb73fcf48 @requirements=[[">=", #<Gem::Version "0">]], @version=nil>
# loaded_from=nil
# extensions=[]
# has_rdoc=true
# rubygems_version="1.3.5"
# post_install_message=nil
# name=nil
# files=[]
# require_paths=["lib"]
# rubyforge_project=nil
# test_files=[]
# summary=nil
# extra_rdoc_files=[]
# cert_chain=[]
# homepage=nil
# dependencies=[]
# platform="ruby"
# licenses=[]
# date=Tue Dec 29 00:00:00 -0500 2009
# original_platform=nil
# requirements=[]
# executables=[]
# authors=[]
# signing_key=nil
# default_executable=nil
# version=nil
# required_rubygems_version=#<Gem::Requirement:0xb73fcf0c @requirements=[[">=", #<Gem::Version "0">]], @version=nil>
# bindir="bin"
# description=nil

Gem::Specification.new do |s|
  s.name = 'bitstring'
  s.version = BitString::VERSION
 
  s.authors = 'Rodent of Unusual Size'
  s.email = 'The.Rodent.of.Unusual.Size@GMail.Com'
  s.date = Time.now.strftime('%Y-%m-%d')

  s.description = %q{FTO is an extensible Ruby library for formatting text strings.  In function it is similar to <tt>printf(3)</tt>; however, the syntax of the format effectors (sometimes called 'format descriptors') and the selection of effectors bundled with the package are based on the SYS$FAO user-mode system service found on OpenVMS.}
  s.summary = %q{An extensible Ruby library for formatting text strings.}

  s.email = %q{The.Rodent.of.Unusual.Size@GMail.Com}
#  s.extra_rdoc_files = ["README.rdoc", "CONTRIBUTORS.rdoc"]
#  s.executables = ["file1", "file2"]
#  s.default_executable = %q{file1}
  s.add_dependency('locale', '>= 2.0.5')
  s.add_dependency('versionomy', '>= 0.3.0')
  s.homepage = %q{http://bitstring.rubyforge.org/}
  s.rubyforge_project = 'bitstring'
  s.rubygems_version = %q{1.3.4}
  s.files = [
             'CONTRIBUTORS.txt',
             'LICENCE.txt',
             'NOTICE.txt',
             'README.txt',
             'Changelog.txt',
             'lib/bitstring.rb',
             'lib/bitstring/operators.rb',
            ] +
    Dir['test/Rakefile'] +
    Dir['test/test_*.rb'] +
    Dir['doc/**/*']
  s.test_files = Dir['test/test_*.rb']

end
