Gem::Specification.new do |s|
  # Project
  s.name         = 'libxml_rails'
  s.summary      = "Libxml_rails replaces ActiveSupport's XmlSimple XML parsing with libxml-ruby."
  s.description  = "Libxml_rails replaces ActiveSupport's XmlSimple XML parsing with libxml-ruby. Original gem by Brandon Mitchell, this fork is by Wes 'Narnach' Oldenbeuving."
  s.version      = '0.0.2.1'
  s.date         = '2008-10-02'
  s.platform     = Gem::Platform::RUBY
  s.authors      = ["Brandon Mitchell", "Wes Oldenbeuving"]
  s.email        = "narnach@gmail.com"
  s.homepage     = "http://www.github.com/Narnach/libxml_rails"

  # Files
  root_files     = %w[CHANGELOG init.rb libxml_rails.gemspec MIT-LICENSE Rakefile README.rdoc]
  lib_files      = %w[bitbckt/core_ext/hash/conversions narnach/core_ext/hash/conversions libxml_rails]
  spec_files     = %w[from_xml]
  other_files    = %w[spec/spec_helper.rb]
  s.require_path = "lib"
  s.executables  = []
  s.test_files   = spec_files.map {|f| 'spec/%s_spec.rb' % f}
  s.files        = root_files + s.test_files + other_files + lib_files.map {|f| 'lib/%s.rb' % f}

  # rdoc
  s.has_rdoc         = true
  s.extra_rdoc_files = %w[ README.rdoc MIT-LICENSE]
  s.rdoc_options << '--inline-source' << '--line-numbers' << '--main' << 'README.rdoc'

  # Dependencies
  s.add_dependency 'activesupport', '= 2.1.0'
  s.add_dependency 'libxml-ruby', '= 0.8.3'

  # Requirements
  s.required_ruby_version = ">= 1.8.0"
end
