
module ArtificerRuby
  class Routines
    ##
    # Copies artifacts from remote repo to local repo
    #
    # Accepted arguments: ['/path_name/'] (default: path='/')
    #
    # *Only cached artifacts can be copied so cache them first with #cache_remote_repository()

    def copy_remote_repository_cache(args=Array.new)
      # path:   '/repodata/'

      path = args.shift || '/'
      return if ! valid_path?(path)

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
  end
end
