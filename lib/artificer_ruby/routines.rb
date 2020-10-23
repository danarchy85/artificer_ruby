require "artificer_ruby/routines/cache_remote_repository"
require "artificer_ruby/routines/copy_remote_repository_cache"

module ArtificerRuby
  class Routines
    def initialize
      @cfg = ArtificerRuby::Config.new
    end

    def run_routines
      start = Time.now.utc
      puts "Running routines: #{start}"
      @cfg.repo_groups.keys.each do |repo_group|
        puts "Running routines for repository group: #{repo_group}"
        @cfg.load(repo_group)
        @repos = ArtificerRuby::Repositories.new(@cfg)
        @repos.apply_all

        if @cfg.routines.nil?
          puts "No routines defined in configuration."
          next
        end

        @cfg.routines.each do |routine|
          if routine.class == String
            self.send(routine)
          elsif routine.class == Hash
            args    = routine.values.first.dup
            routine = routine.keys.first
            self.send(routine, args)
          else
            puts "Invalid format for routine: #{routine}. Needs to be a string or hash."
            next
          end
        end
      end

      finish = Time.now.utc
      print "Finished: #{finish} "
      puts "(#{(finish - start).round(2)} seconds)"
    end

    def prepare_new_local_repository
      @remove, @add = @repos.generate_local_datestamp_repository
    end

    def update_virtual_repositories
      return if @remove.nil? || @add.nil?
      @repos.update_virtual_repositories(@remove, @add)
    end

    private
    def valid_path(path)
      if path != '/' && path !~ /^\/.*\/$/
        puts "Path '#{path}' must begin and end with a forward slash."
        return false
      end

      true
    end
  end  
end
