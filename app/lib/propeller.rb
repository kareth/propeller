class Propeller
  require 'propeller/image_processor'
  require 'propeller/interface'

  def initialize
    @interface = Interface.new
    @processor = ImageProcessor.new
  end

  # Runs chosen command
  # @note By far it ignores any command
  # @note In the future, it should take some kind of communication information as args
  def run command, args
    @interface.show
  end

  # Notify processor about pending file to process
  # @param path [String] path to selected raw image
  # @param placement [Hash] placement of the image on the propeller display, including Width(w), Height(h), XOffset(x), YOffset(y)
  def image_loaded path, placement = {}
    @processor.process path, args
  end

  # Notify interface about finished image processing
  # @param path [String] path to processed image
  def image_processed path
    @interface.processed path
  end

  # Transmits information about selected image to propeller microprocessor
  def transmit
  end

  # Stops the propeller machine
  def stop
  end

  # Starts up the propeller machine
  def start
  end

  # Exits the propeller program including:
  # - stopping the propeller machine
  # - closing the interface
  def exit
    @interface.hide
    # sth to destroy all dat shit??
    # Shut down propeller
  end
end
