class Propeller
  require 'propeller/image_processor'

  def initialize shoes
    @interface = shoes
    @processor = ImageProcessor.new
  end

  def current_image
    @current_image
  end

  # Runs chosen command
  # @note By far it ignores any command
  # @note In the future, it should take some kind of communication information as args
  def run command, args
    @interface.show
  end
  
  # Process image stored on passed url
  # @param path [String] path to selected raw image
  # @param placement [Hash] placement of the image on the propeller display, including Width(w), Height(h), XOffset(x), YOffset(y)
  def process_image path, placement = {}
    @current_image = @processor.process path, placement
    @interface.processed @current_image
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
