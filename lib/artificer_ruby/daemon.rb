require "artificer_ruby/daemon/pid"

module ArtificerRuby
  ##
  # Forks a process with PID writen to /tmp/ and keeps the runner alive.
  #
  # This works in such a way that allows ArtificerRuby to run, start the daemon, and exit.
  # Then at a later time be ran again to reattach to the PID and check its status or stop it.

  class Daemon
    attr_reader :runner

    def initialize
      @cfg = ArtificerRuby::Config.new
    end

    ##
    # Starts the daemon's forked process; reopens $stderr and $stdout

    def start
      running, pid = status
      return if running == true
      puts "Starting Daemon"

      pid = fork do
        $stdin.reopen '/dev/null'
        $stdout.reopen @cfg.logout
        $stderr.reopen @cfg.logerr

        runner = ArtificerRuby::Runner.new

        trap(:HUP) do
          puts 'Ignoring SIGHUP'
        end

        trap(:TERM) do
          puts "Caught signal: TERM. Shutting down Daemon..."
          runner.stop
          exit(0)
        end

        loop do
          runner.start if runner.status == false
          sleep(15)
        end
      end

      Process.detach(pid)
      Pid.new
    end

    ##
    # Checks the status of the daemon based on PID.
    #
    # Also see Pid.new()

    def status
      if pid = Pid.new
        begin
          Process.getpgid(pid)
          puts "ArtificerRuby is running as PID: #{pid}"
          return true, pid
        rescue StandardError => e
          puts 'ArtificerRuby is not running!'
          return false, pid
        end
      else
        puts "ArtificerRuby is not currently running."
        return false, pid
      end
    end

    ##
    # Stops a running process by sending it a trap(:TERM) signal.

    def stop
      running, pid = status
      if running == true
        Process.kill('TERM', pid)

        print 'Waiting for ArtificerRuby to quit.'
        while Pid.is_running? == true
          sleep(1)
          print '.'
        end

        if Pid.is_running? == true
          puts "\nFailed to stop Daemon"
          false
        else
          puts "\nStopped Daemon"
          true
        end
      else
        false
      end
    end
  end
end
