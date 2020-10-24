
##
# ArtificerRuby::Repositories

module ArtificerRuby
  ##
  # ArtificerRuby::Repositories holds a @repos hash of loaded Artifactory::Repository objects
  #
  # Must run Config.load(repo_group) first to load repositories and pass into Repositories.new() as an argument

  class Repositories
    attr_reader :group
    attr_reader :repos

    ##
    # initialize repos from cfg.repos
    #
    # Must run Config.load(repo_group) first to load repositories and pass into Repositories.new() as an argument

    def initialize(cfg)
      if cfg.loaded.nil?
        puts 'Load a repository group with cfg.load(rgroup) first!'
        return
      end

      @cfg   = cfg
      @group = cfg.loaded
      @repos = Hash.new
      load
    end

    def load
      @cfg.repos.each { |k, r| @repos[k] = Repository.new(r) }
      Helpers.parse_attributes(self, @repos)
    end

    ##
    # Generates a new local repo with name build from
    #  remote_repo_name + Time.now.utc strftime'd as @cfg.date_format

    def generate_and_archive_local_repository
      remove = self.send('local').key
      add = self.send('remote').key.gsub(/remote/, 'local')
      add += '.' + Time.now.utc.strftime(@cfg.date_format)

      archive = @cfg.repos['local'].dup
      generate_archive
      @cfg.archive.push(archive)
      puts "Archived: #{remove}"

      puts "New local repository: #{add}"
      @cfg.local['key'] = add
      @cfg.save
      load
      apply('local')
      [remove, add]
    end

    ##
    # Replace virtual repository

    def update_virtual_repositories(remove, add)
      i = @cfg.virtual['repositories'].find_index(remove)
      @cfg.virtual['repositories'][i] = add
      @cfg.save
      load
      puts "Swapped virtual repository: #{remove} => #{add}"
      apply('virtual')
    end

    ##
    # Creates or updates a repository in Artifactory
    #
    # provide a repo key: ['local','remote','virtual'], not a repository name

    def apply(repo)
      print 'Applying repository: '
      r = self.send(repo)
      puts r.key
      r.save
    end

    ##
    # Loop through and create or update all repositories in the loaded repository group

    def apply_all
      @repos.keys.each { |k| apply(k) }
    end

    ##
    # Deletes a repository in Artifactory
    #
    # provide a repo key: ['local','remote','virtual'], not a repository name

    def delete(repo)
      print 'Deleting repository: '
      r = self.send(repo)
      puts r.key
      r.delete
    end

    ##
    # Loop through and delete all repositories in the loaded repository group

    def delete_all
      @repos.keys.each { |k| delete(k) }
    end

    ##
    # Generates an empty archive for the loaded repository group

    def generate_archive
      return if @cfg.archive
      @cfg.rgroup['archive'] = Array.new
      @cfg.save
      @cfg.load(@group)
    end

    ##
    # Deletes all archives

    def cleanup_archive
      return if @cfg.archive.empty?
      until @cfg.archive.empty?
        repo = @cfg.archive.shift
        puts "Cleaning up archive: #{repo['key']}"
        Repository.new(repo).delete
      end

      @cfg.save
    end
  end
end
