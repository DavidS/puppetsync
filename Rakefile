#!/opt/puppetlabs/bolt/bin/rake -f
require 'rake/clean'

BOLT_BIN_PATH="/opt/puppetlabs/bolt/bin"
BOLT_GEM_EXE=File.join(BOLT_BIN_PATH,'gem')
BOLT_PUPPET_EXE=File.join(BOLT_BIN_PATH,'puppet')
BOLT_EXE=File.join(BOLT_BIN_PATH,'bolt')
GEM_HOME='.gems'

CLEAN.include( Dir['????????-????-????-????-????????????'].reject{|x| x.strip !~ /^[\h-]{36}$/ } )
CLEAN.include( [GEM_HOME, 'tmpdir', 'gem.deps.rb.lock'] )
CLOBBER << '_repos'

desc <<~DESC
  Generate REFERENCE.md for puppetsync

  (TODO: after breaking puppetsync into its own module, document roles & profiles)
DESC

task :strings, [:verbose] do |t,args|
  args.with_defaults(:verbose => false)
  sh %Q[#{BOLT_PUPPET_EXE} strings generate \
     #{args.verbose ? ' --verbose' : '' } --format markdown \
     "{dist,site-modules}/**/*.{pp,rb,json}"].gsub(/ {3,}/,' ')
end

namespace :install do
  desc "Install gems into #{__dir__}/.gems"
  task :gems do
    Dir.chdir __dir__
    sh %Q[GEM_HOME="#{GEM_HOME}" "#{BOLT_GEM_EXE}" install -g gem.deps.rb --no-document --no-user-install]
    sh %Q[ls -lart]
  end

  desc "Install modules from Puppetfile into #{__dir__}/modules"
  task :puppetfile do
    Dir.chdir __dir__
    sh %Q[GEM_HOME="#{GEM_HOME}" "#{BOLT_EXE}" puppetfile install]
  end
end

namespace :list do
  desc "Installed gems (pass in true to list only project gems)"
  task :gems, :project_only do |t,args|
    args.with_defaults(:project_only => false)
    Dir.chdir __dir__
    cmd =%Q[GEM_HOME="#{GEM_HOME}" "#{BOLT_GEM_EXE}" list]
    cmd ="GEM_PATH= #{cmd}" if args.project_only
    sh cmd
  end
end

desc 'Install prereqs'
task :install => ['install:gems', 'install:puppetfile']

task :default => :install
