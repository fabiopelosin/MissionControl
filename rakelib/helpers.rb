
require 'pathname'

module Helpers

  class << self

    # @return []
    #
    def gem_proper_name(gem)
      map = {
        "CLAide" => "claide",
        "CocoaPods" => "cocoapods",
        "Core" => "cocoapods-core",
        "Xcodeproj" => "xcodeproj",
        "cocoapods-downloader" => "cocoapods-downloader",
      }
      result = map[gem]
      error "Unable to find proper name of gem" unless result
      result
    end

    # @return []
    #
    def gem_version_files(gem)
      path = Pathname.new("#{gem}/lib/#{gem_proper_name(gem)}/gem_version.rb")

      unless path.exist?
        error "Unable to find gem version file for #{gem}"
      end
      path
    end

    # @return []
    #
    def new_version_acceptable?(old_version, new_version)
      old_components = old_version.split('.').map(&:to_i)
      new_components = new_version.split('.').map(&:to_i)
      if old_version == new_version
        error "New version identical to old one"
      elsif old_components[0] != 0 && new_components[0] != 0
        error "CocoaPods ins't ready for prime time yet"
      elsif old_components[1] != new_components[1]
        error "Bump only by one" if old_components[1] + 1 != new_components[1]
        error "Bump in minor versions require a 0 patch level"  if new_components[2] != 0
      elsif old_components[2] != new_components[2]
        error "Bump only by one" if old_components[2] + 1 != new_components[2]
      end
    end

    def gem_version_file(gem, new_version, changelog)
      version_constant = "Pod::VERSION"
      template = <<-EOF

# The version of the #{gem} gem.
#
#{version_constant} = '#{new_version}' unless defined? #{version_constant}

      EOF

      if gem == 'CocoaPods'
        changelog_template = <<-OEF

# The changelog of this version
#
Pod::CHANGELOG = <<-LOG\n
#{changelog}
LOG
OEF

template << changelog_template
      end
      template
    end

    #--------------------------------------------------------------------------------#

    def cocoapods_changelog_path
      Pathname.pwd + 'CocoaPods'
    end

    # require 'changelogs'

    # @return [String]
    #
    def changelog_fragment(version)
      p Changelogs::Log.log_from_dir(cocoapods_changelog_path).log_for_last_version(true)
    end

  end
end
