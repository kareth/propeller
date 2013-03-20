class Propeller
  require 'propeller/image_processor'
  require 'propeller/interface'

  def initialize
    @interface = Interface.new
    @processor = ImageProcessor.new
  end

  def run command, args
    puts "Command: '#{command}'"
    puts "Args: '#{args.join(", ")}'"

    @interface.show
  end

  def image_loaded path, args = {}
    @processor.process path, args
  end

  def image_processed path
    @interface.processed path
  end

  def transmit
  end

  def stop
  end

  def start
  end

  def exit
    @interface.hide
    # sth to destroy all dat shit??
  end
end
