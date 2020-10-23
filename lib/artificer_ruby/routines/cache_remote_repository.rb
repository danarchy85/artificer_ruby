
module ArtificerRuby
  class Routines
    ##
    # Cache a remote repository's artifacts
    #
    # Accepted arguments: ['path_name', limit=Int] (default: path='/', limit=nil)
    #
    # JFrog Artifactory and the Ruby 'Artifactory' client appear to only list cached files
    # and cannot copy uncached files it cannot see.
    #
    # This method scrapes Artifactory's HTML output of a repository and requests each
    # file to force Artifactory to cache them.

    def cache_remote_repository(args=Array.new)
      # path: '/repodata/'
      # limit: Int # used for debugging to only process the first N artifacts
      # http_timeout: Int # Timeout in seconds for each HTTP request

      path  = args.shift || '/'
      limit = args.shift || nil
      return if ! valid_path?(path)
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
  end
end
