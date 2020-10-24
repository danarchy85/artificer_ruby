
##
# ArtificerRuby::Config

require 'fileutils'
require 'yaml'

module ArtificerRuby
  ##
  # ArtificerRuby::Config handles application, authentication and
  # repository group configuration.
  ##
  # @auth:    authentication credentials from auth.yaml
  #
  # @config:  application configuration  from config.yaml
  #
  # @rgroups: repository groups from repository_groups.yaml
  ##
  # runing #load(repo_group) with a defined rgroup will load that
  # group's repositories, routines, and archive accessible through
  # @repos, @routines, @archives

  class Config
    attr_reader :cfgdir
    attr_reader :logdir
    attr_reader :logout
    attr_reader :logerr

    attr_reader :auth
    attr_reader :config
    attr_reader :rgroups

    attr_accessor :archive
    attr_reader :loaded
    attr_reader :repos
    attr_reader :rgroup
    attr_reader :routines

    def initialize
      @cfgdir  = File.realpath(ENV['HOME']) +
                 '/.config/artificer_ruby'
      @logdir = @cfgdir + '/logs/'
      @logout = @logdir + 'stdout.log'
      @logerr = @logdir + 'stderr.log'
      load
    end

    ##
    # load() loads config and no repository group
    #  @config  = config.yaml
    #  @auth    = auth.yaml
    #  @rgroups = repository_groups.yaml
    #
    # load(rgroup) loads the specified repository group
    #
    # Running load() again without an argument will unload the loaded repository group
    #
    # alternatively, Config.new can be called again to reload the base configuration

    def load(rgroup=nil)
      @config  = load_parameters('config.yaml')
      @auth    = load_parameters('auth.yaml')
      @rgroups = load_parameters('repository_groups.yaml')

      if rgroup
        if @rgroups.keys.include?(rgroup)
          @rgroup   = @rgroups[rgroup]
          @routines = @rgroup['routines']
          @archive  = @rgroup['archive']
          @repos    = @rgroup['repos']
          @loaded   = rgroup
          Helpers.parse_attributes(self, repos)
        else
          puts "Repository group '#{rgroup}' does not exist!"
          return false
        end
      elsif rgroup.nil? && @rgroup
        unset = Hash.new # unset current repo attributes
        @repos.keys.each { |k| unset[k] = nil }
        Helpers.parse_attributes(self, unset)

        unset = Hash.new # unset rgroup attributes
        @rgroup.keys.each { |k| unset[k] = nil }
        Helpers.parse_attributes(self, unset)

        @loaded, @rgroup, @repos = nil, nil, nil
      end
    end

    ##
    # save changes in @config or @rgroups

    def save
      File.write(@cfgdir + '/config.yaml', @config.to_yaml)
      File.write(@cfgdir + '/repository_groups.yaml', @rgroups.to_yaml)
    end

    private
    ##
    # loads the provided yaml file if it exists, or generates it
    # from default configs passing them through the user's editor
    # for modification

    def load_parameters(yaml)
      if ! Dir.exist?(@cfgdir)
        puts "Creating configuration directories at: #{@cfgdir}"
        Dir.mkdir(@cfgdir)
      end

      Dir.mkdir(@logdir) if ! Dir.exist?(@logdir)

      @cfgyaml = @cfgdir + '/' + yaml
      if ! File.exist?(@cfgyaml)
        template = File.dirname(__FILE__) + '/config/' + yaml
        FileUtils.cp(template, @cfgyaml)
        Helpers.editor(@cfgyaml, prompt=true)
      end

      Helpers.parse_attributes(self, YAML.load_file(@cfgyaml))
    end

  end
end

