
module ArtificerRuby
  class Repositories
    def initialize(cfg)
      @cfg   = cfg
      @repos = Hash.new
      load
    end

    def load
      @cfg.repos.each do |k, r|
        next if %w[archive routines].include?(k)
        @repos[k] = Repository.new(r)
      end

      Helpers.parse_attributes(self, @repos)
    end

    def generate_local_datestamp_repository
      # Generates a new local repo with name build from
      #  remote_repo_name + Time.now.utc strftime'd as @cfg.date_format
      remove = self.send('local').key
      add = self.send('remote').key.gsub(/remote/, 'local')
      add += '.' + Time.now.utc.strftime(@cfg.date_format)
      archive = @cfg.repos['local'].dup
      @cfg.archive.push(archive)
      puts "Archived: #{remove}"
      puts "New local repository: #{add}"
      @cfg.local['key'] = add
      @cfg.save
      load
      apply('local')
      [remove, add]
    end

    def update_virtual_repositories(remove, add)
      # Replace virtual repository
      i = @cfg.virtual['repositories'].find_index(remove)
      @cfg.virtual['repositories'][i] = add
      @cfg.save
      load
      puts "Swapped virtual repository: #{remove} => #{add}"
      apply('virtual')
    end

    def apply_all
      @repos.keys.each do |k|
        next if k == 'archive'
        apply(k)
      end
    end

    def apply(repo)
      print 'Applying repository: '
      r = self.send(repo)
      puts r.key
      r.save
    end

    def delete_all
      @repos.keys.each do |k|
        next if k == 'archive'
        delete(k)
      end
    end

    def delete(repo)
      print 'Deleting repository: '
      r = self.send(repo)
      puts r.key
      r.delete
    end

    def cleanup_archives
      @cfg.archive.each do |repo|
        puts "Cleaning up archive: #{repo['key']}"
        Repository.new(repo).delete
      end

      @cfg.repos['archive'] = Array.new
      @cfg.save
    end
  end
end
