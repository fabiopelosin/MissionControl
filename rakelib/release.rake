
desc "Pushes a new CocoaPods release"
task :release do

  current_gem_versions = compute_current_gem_versions

  title 'Updating repos'
  update_repos

  exit!

  title 'Checking gems which need release'
  gems = gems_that_need_release(current_gem_versions)

  title 'Performing pre-release checks'
  pre_release_check(gems)

  title 'Set new versions'
  # get_new_gem_versions(gems, current_gem_versions)

  change_log_new_version = '0.22.2'

  title 'Changelog'
  puts Helpers.changelog_fragment(change_log_new_version)
  puts yellow("\nWould you like to update the changelog? (y/n)")
  if $stdin.gets.strip == 'y'
    edit(cocoapods_changelog_path)
    puts Helpers.changelog_fragment(change_log_new_version)
  end

  title 'Updating versions, dependencies & changelog'
  gem = 'CocoaPods'
  puts Helpers.gem_version_file(gem, new_version, Helpers.changelog_fragment(change_log_new_version))
  # Update version
  # Update dependencies
  # Helpers.changelog_fragment

  title 'Performing pre-release updates'
  gems.each do |gem|
    # update bundler
    #     puts "Updating Bundles"
    # silent_sh('bundle update')#
  end

  title 'Running tests'
  # specs
  # puts "* Running specs"
  # silent_sh('rake spec:all')

  # gem installation
  # tmp = File.expand_path('../tmp', __FILE__)
  # tmp_gems = File.join(tmp, 'gems')

  # Rake::Task['gem:build'].invoke

  # puts "* Testing gem installation (tmp/gems)"
  # silent_sh "rm -rf '#{tmp}'"
  # silent_sh "gem install --install-dir='#{tmp_gems}' #{gem_filename}"


  title 'Releasing'
  # sh "git commit lib/cocoapods-core/gem_version.rb -m 'Release #{gem_version}'"
  # sh "git tag -a #{gem_version} -m 'Release #{gem_version}'"
  # sh "git push origin master"
  # sh "git push origin --tags"
  # sh "gem push #{gem_filename}"

  title 'Performing post release actions'
  # Updates specs repo last version
  # Update docs
end

task :yolo => :release

# Release taks

#--------------------------------------------------------------------------------#

def update_repos
  gem_dirs.each do |gem|
    Dir.chdir(gem) do
      subtitle gem
      sh "git pull"
      puts "\n"
    end
  end
end

def gems_that_need_release(current_versions)
  result = []
  gem_dirs.each do |gem|
    if gem_needs_release?(gem, current_versions)
      puts green("  - [YES] #{gem} (#{current_versions[gem]})")
      result << gem
    else
      puts "  - [NO]  #{gem} (#{current_versions[gem]})"
    end
  end
  result << "CocoaPods" if result.include?('Core')
  result << "Core" if result.include?('CocoaPods')
  result.uniq
end

def pre_release_check(gems)
  gems.each do |gem|
    Dir.chdir(gem) do
      subtitle(gem)

      if `git symbolic-ref HEAD 2>/dev/null`.strip.split('/').last != 'master'
        $stderr.puts "[!] You need to be on the `master' branch in order to be able to do a release."
        exit 1
      end
      puts "  - On master branch"


      diff_lines = `git diff --name-only`.strip.split("\n")

      diff_lines.delete('Gemfile.lock')
      if diff_lines.size != 0
        $stderr.puts "[!] Repo no clean"
        $stderr.puts diff_lines
        exit 1
      end
      puts "  - Index clean"


      puts "\n"
    end
  end
end

def tags_check(gems)
  gems.each do |gem|
    Dir.chdir(gem) do
      if `git tag`.strip.split("\n").include?(gem_version)
        $stderr.puts "[!] A tag for version `#{gem_version}' already exists. Change the version in lib/cocoapods-core/.rb"
        exit 1
      end

      puts "You are about to release `#{gem_version}', is that correct? [y/n]"
      exit if $stdin.gets.strip.downcase != 'y'
    end
  end
end

# @return [Hash{String=>String}]
#
def get_new_gem_versions(gems, current_gem_versions)
  new_versions = {}
  gems.each do |gem|
    next if gem == 'Core'
    Helpers.gem_version_files(gem)
    subtitle(gem)
    puts yellow("enter new version (current one is #{current_gem_versions[gem]}):")
    new_versions[gem] = $stdin.gets.strip
    Helpers.new_version_acceptable?(current_gem_versions[gem], new_versions[gem])
    puts "\n"
  end
  new_versions['Core'] = new_version['CocoaPods']
  new_versions
end


# Data

#--------------------------------------------------------------------------------#

def gem_dirs
  Dir.glob('*/').map { |dir| dir.sub('/','') } - ['Docs', 'Specs', 'rakelib']
end


# Primitive helpers

#--------------------------------------------------------------------------------#

# @return [Hash{String=>String}]
#
def compute_current_gem_versions
  result = {}
  gem_dirs.each do |gem|
    result[gem] = last_tag(gem)
  end
  result
end

# @return [Bool]
#
def gem_needs_release?(gem, current_versions)
  Dir.chdir(gem) do
    last_gem_tag = current_versions[gem]
    tag_commit(last_gem_tag)
    head_commit(last_gem_tag)
    has_update = tag_commit(last_gem_tag) != head_commit(last_gem_tag)
  end
end

# @return [String]
#
def last_tag(gem)
  Dir.chdir(gem) do
    tags = `git for-each-ref --sort='*authordate' --format='%(refname:short)' refs/tags`
    tags.split("\n").last
  end
end

def tag_commit(tag)
  `git rev-parse --verify #{tag}^0`.chomp
end

def head_commit(tag)
  `git rev-parse HEAD`.chomp
end

def edit(file)
  editor = `git config --global core.editor`.chomp
  sh "#{editor} #{file}"
end

def silent_sh(command)
  output = `#{command} 2>&1`
  unless $?.success?
    puts output
    exit 1
  end
  output
end





