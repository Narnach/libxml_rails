require 'rubygems'
require 'rake'

begin
  require 'echoe'
  Echoe.new('libxml_rails', '0.0.1') do |p|
    p.summary = 'A plugin substituting libxml-ruby for XmlSimple in Rails.'
    p.url = 'http://github.com/bitbckt/libxml_rails'
    p.author = 'Brandon Mitchell'
    p.email = 'brandon (at) systemisdown (dot) net'
    p.runtime_dependencies = ['activesupport >= 2.1.0', 'libxml-ruby >=0.8.3']
  end
rescue LoadError => boom
  puts 'You are missing a dependency required for meta-operations on this gem.'
  puts boom.to_s.capitalize
end
 
desc 'Install the package as a gem, without generating documentation(ri/rdoc)'
task :install_gem_no_doc => [:clean, :package] do
  sh "#{'sudo ' unless Hoe::WINDOZE }gem install pkg/*.gem --no-rdoc --no-ri"
end

desc 'Run specs'
Spec::Rake::SpecTask.new do |t|
  t.spec_opts = ['--format', 'specdoc', '--colour', '--diff']
end