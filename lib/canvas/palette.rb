require 'logger'
module Canvas
  module Palette
    def configure(&block)
      block.call(self) if block_given?
      @logger ||= Logger.new(STDOUT)
    end

    def logger(level, message)
      case
        when @logger.respond_to?(level) then @logger.send(level, message)
        when @logger.respond_to?(:puts) then @logger.puts "#{level}: #{message}"
        else $stderr.puts "#{level}: #{message}"
      end
    end
  end

end