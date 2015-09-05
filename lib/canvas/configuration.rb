require 'logger'
module Canvas
  attr_writer :logger
  def self.configure(&block)
    block.call(self) if block_given?
    @logger ||= Logger.new(STDOUT)
  end

  def self.logger(level, err)
    if @logger.respond_to?(level)
      @logger.send(level, err.error)
      @logger.send(level, err.backtrace)
    elsif @logger.respond_to?(:puts)
      @logger.puts "#{level}: #{err.message}"
      @logger.puts "#{level}: #{err.backtrace}"
    else
      $stderr.puts "#{level}: #{err.message}"
      $stderr.puts "#{level}: #{err.backtrace}"
    end
  end
end