
module ArtificerRuby
  class Routines
    def initialize(cfg)
      @cfg = cfg
    end

    def run_routines
      start = Time.now.utc
      puts "Running routines: #{start}"
      @cfg.repo_groups.keys.each do |repo_group|
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

    def cache_remote_repository(args=Array.new)
      # path: '/repodata/'
      # limit: Int # used for debugging to only process the first N artifacts
      # http_timeout: Int # Timeout in seconds for each HTTP request

      # JFrog Artifactory and this Ruby client appear to only list cached files
      # This method scrapes Artifactory's HTML output of a repo and requests each
      #  file to force Artifactory to cache them.

      path  = args.shift || '/'
      limit = args.shift || nil
      return if ! valid_path(path)
      r = @repos.remote
      source_path = r.key + path
      files = Array.new

      begin
        files = Artifactory.client.get(source_path).split(/\n/).collect do |href|
          next if href !~ /^<a href/
          href.split(/\"/)[1]
        end.compact
        puts 'Caching artifacts in: ' + r.key + path
      rescue StandardError => e
        puts e
        return
      end

      i = 1
      files.each do |file|
        uri = URI(Artifactory.endpoint + source_path + file)
        req = Net::HTTP::Get.new(uri)
        print "Caching: #{uri}"

        if api_key = Artifactory.api_key
          req.add_field("X-JFrog-Art-Api", api_key)
        else
          req.basic_auth(Artifactory.username, Artifactory.password)
        end

        use_ssl = uri.scheme == 'https' ? true : false
        Net::HTTP.start(req.uri.host, req.uri.port,
                        read_timeout: @cfg.http_timeout || 300, use_ssl: use_ssl) do |http|
          begin
            response = http.request(req)
          rescue StandardError => e
            puts "\r"
            puts e
            i += 1
            next
          end

          if response.kind_of?(Net::HTTPFound)
            puts "\rCached (#{i}/#{files.count}): #{file}"
          else
            puts "\rReceived response: #{response.response} for #{file}"
          end
        end

        i += 1
        break if limit && i > limit
      end
    end

    def copy_remote_repository_cache(args=Array.new)
      # path:   '/repodata/'

      # Copies artifacts from remote repo to local repo
      #  *Only cached artifacts can be copied so cache them first with #cache_remote_repository()

      path = args.shift || '/'
      return if ! valid_path(path)

      r_remote = @repos.remote
      r_local  = @repos.local
      source_path = '/api/copy/' + r_remote.key + '-cache' + path
      target_path = '?to=' + r_local.key

      begin
        response = Artifactory.client.post(source_path + target_path, Hash.new)
        message = response['messages'].first['message']
      rescue StandardError => message
      ensure
        puts message
      end
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
