require 'colorize'

class Synchronization::Engine::Lib::Logger

  class << self

    def success(message)
      write message.to_s.green
    end

    def error(message)
      write message.to_s.red
    end

    def info(message)
      write message.to_s.blue
    end

    def warning(message)
      write message.to_s.yellow
    end

    private

    def write(message)
      puts(message)
      Rails.logger.info(message)
    end

  end
end
