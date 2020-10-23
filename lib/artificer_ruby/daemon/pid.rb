
module ArtificerRuby
  class Daemon
    class Pid
      def self.new
        pidfile = '/tmp/artificer_ruby.pid'
        if File.exist?(pidfile)
          if is_running?
            File.read(pidfile).chomp.to_i
          else
            File.delete(pidfile)
            nil
          end
        elsif is_running?
          File.write(pidfile, @pid)
          @pid
        else
          nil
        end
      end

      def self.is_running?
        pids = `pgrep -f "artificer_ruby start"`.split(/\n/).map(&:to_i).grep_v(Process.pid)
        if pids.any?
          @pid = pids.first
          true
        else
          false
        end
      end
    end
  end
end
