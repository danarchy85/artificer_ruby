require "artifactory"
require "artificer_ruby/config"
require "artificer_ruby/helpers"
require "artificer_ruby/repositories"
require "artificer_ruby/routines"
require "artificer_ruby/version"

include Artifactory::Resource
module ArtificerRuby
  def self.new
    cfg = ArtificerRuby::Config.new
    connect_to_artifactory(cfg)
    r = ArtificerRuby::Routines.new(cfg)
    r.run_routines
  end

  private
  def self.connect_to_artifactory(cfg)
    cfg.auth.each do |k, v|
      next if v.nil?
      begin
        Artifactory.send(k)
        Artifactory.instance_variable_set("@#{k}", v)
      rescue StandardError => e
        puts "Invalid Artifactory credentials: #{e}"
      end
    end

    if System.ping
      puts "Connected to Artifactory: #{Artifactory.endpoint}"
    else
      abort('Failed to connect to Artifactory!')
    end
  end
end
