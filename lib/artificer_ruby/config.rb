
require 'fileutils'
require 'yaml'

module ArtificerRuby
  class Config
    attr_reader :auth
    attr_reader :cfgdir
    attr_reader :cfgerr
    attr_reader :logdir
    attr_reader :logout
    attr_reader :logerr
    attr_reader :config
    attr_reader :repo_groups
    attr_reader :repos
    attr_reader :routines

    def initialize
      @cfgdir  = File.realpath(ENV['HOME']) +
                     '/.config/artificer_ruby'
      @logdir = @cfgdir + '/logs/'
      @logout = @logdir + 'stdout.log'
      @logerr = @logdir + 'stderr.log'
      load
    end

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

    def load(repo_group=nil)
      @config      = load_parameters('config.yaml')
      @auth        = load_parameters('auth.yaml')
      @repo_groups = load_parameters('repository_groups.yaml')
      if repo_group
        if @repo_groups.keys.include?(repo_group)
          @repos = Helpers.parse_attributes(self, @repo_groups[repo_group])
        else
          puts "Repo group '#{repo_group} does not exist!"
        end
      end
    end

    def save
      File.write(@cfgdir + '/config.yaml', @config.to_yaml)
      File.write(@cfgdir + '/repository_groups.yaml', @repo_groups.to_yaml)
    end
  end
end

