require "artifactory"
require "rufus-scheduler"
require "artificer_ruby/config"
require "artificer_ruby/daemon"
require "artificer_ruby/helpers"
require "artificer_ruby/repositories"
require "artificer_ruby/routines"
require "artificer_ruby/version"

include Artifactory::Resource

##
# ArtificerRuby

module ArtificerRuby
  def self.new
    cfg = ArtificerRuby::Config.new
    connect_to_artifactory(cfg)
    cfg
  end

  ##
  # Runner initializes and runs Rufus-Scheduler
  # to run routines based on the defined cron

  class Runner
    attr_reader :scheduler

    def initialize
      @cfg = ArtificerRuby::Config.new
    end

    def start
      return if status
      puts 'Starting ArtificerRuby'
      @scheduler = Rufus::Scheduler.new

      @scheduler.cron @cfg.schedule do
        begin
          ArtificerRuby.new
          routines = ArtificerRuby::Routines.new
          routines.run_routines
        rescue StandardError => e
          puts e
        end
      end
    end

    def status
      return false if @scheduler.nil?
      @scheduler.jobs.any?
    end

    def stop
      puts 'Stopping ArtificerRuby'
      @scheduler.shutdown(:wait)
      @scheduler = nil
      puts 'Stopped ArtificerRuby'
    end
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
