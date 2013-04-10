# Main class used to communicate between all modules
class Propeller
  require 'propeller/image_processor'
  require 'propeller/interface'
  require 'propeller/preview'
  require 'propeller/transmitter'

  # Initializes propeller class ith external processors:
  # @note interface - managing data being sent to and from user
  # @note propeller_processor - processing image to data readable by robot
  # @note preview_processor - generating preview image basing on propeller data
  def initialize args
    @interface = Interface.new args, self
    @propeller_processor = ImageProcessor.new
    @preview_processor = Preview.new
    @transmitter = Transmitter.new
  end
  
  # Connect transmitter with given serial port
  # @param port [String] - port to connect with i.e. /dev/rfcomm0
  def connect_device port
    @transmitter.connect port
  end

  # Runs chosen command
  # @note By far it ignores any command
  # @note In the future, it should take some kind of communication information as args
  def run command, args
    @interface.show
  end

  # Process image stored in passed url
  # @param path [String] path to selected raw image
  # @param placement [Hash] placement of the image on the propeller display, including Width(w), Height(h), XOffset(x), YOffset(y)
  def process_image path, placement = {}
    p 'Generating propeller data...'
    @propeller_data = @propeller_processor.process path, placement

    p 'Generating preview...'
    @preview = @preview_processor.generate @propeller_data

    @interface.processed @preview
  end

  # Process text specified by user
  # @note not used by far
  def process_text text, color = "#000000"
  end

  # Transmits information about selected image to propeller microprocessor
  def transmit
    @transmitter.transmit @propeller_data
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
