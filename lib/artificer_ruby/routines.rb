require "artificer_ruby/routines/cache_remote_repository"
require "artificer_ruby/routines/copy_remote_repository_cache"

module ArtificerRuby
  ##
  # Houses routines that can be run for a repository group

  class Routines
    def initialize
      @cfg = ArtificerRuby::Config.new
    end

    ##
    # Run all routines for each repository group

    def run_routines
      start = Time.now.utc
      puts "Running routines: #{start}"
      @cfg.rgroups.keys.each do |rgroup|
        puts "\nRunning routines for repository group: #{rgroup}"
        @cfg.load(rgroup)
        @repos = ArtificerRuby::Repositories.new(@cfg)
        @repos.apply_all

        next if @cfg.routines.nil?
        @cfg.routines.each do |routine|
          if routine.class == String
            begin
              self.send(routine)
            rescue StandardError => e
              puts e
              puts "Invalid method: #{routine}. Skipping the rest of this group's repositories."
              next
            end
          elsif routine.class == Hash
            args    = routine.values.first.dup
            routine = routine.keys.first
            begin
              self.send(routine, args)
            rescue StandardError => e
              puts e
              puts "Invalid method: #{routine}. Skipping the rest of this group's repositories."
              next
            end
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

    ##
    # See: ArtificerRuby::Repositories.generate_local_datestamp_repository

    def create_archive_local_repository
      @remove, @add = @repos.generate_and_archive_local_repository
    end

    ##
    # See: ArtificerRuby::Repositories.update_virtual_repositories

    def update_virtual_repositories
      return if @remove.nil? || @add.nil?
      @repos.update_virtual_repositories(@remove, @add)
    end

    private

    ##
    # Validate that the given path begins and ends with a forward slash

    def valid_path?(path)
      if path != '/' && path !~ /^\/.*\/$/
        puts "Path '#{path}' must begin and end with a forward slash."
        return false
      end

      true
    end
  end
end
