require 'serialport'

# Class responsible for data transmition between propeller device and application
class Propeller::Transmitter
  SPEED = 115200 # Data transmition speed in bits / second
  
  # Connects with specified serial port
  # @param port [String] - Serial port descriptor i.e /dev/rfcomm0
  def connect port
    @sp = SerialPort.new port, SPEED
  end
  
  
  # Transmit image given in 2d array to propeller
  # using chosen serial port
  # @param pixels [Array[Array]] - array of hexadecimal pixels values
  def transmit pixels
    pixels = compress convert pixels
    pixels.each { |pixel| @sp.write pixel.chr }
#    @sp.write pixels
  end
  
  # Disconnect serial port
  def disconnect
    @sp.close
  end  
  
  private
    # Upscales value from 8 bit to 12 bit
    # @param value [Integer]
    def upscale value
      (value / 255.0 * 4095.0).to_i % 4096
    end
    
    # Convert 2d array of pixels to flatten thirds of r,g,b
    # values of each pixel in 
    # @param data [Array[Array]] - Array of image pixel values in rgba format
    # @return [Array] - Flatten thirds of decimal r,g,b values
    def convert data
      data.transpose.flatten.map do |pixel| 
        (pixel/256).to_s(16).rjust(6,'0').scan(/.{2}/).first(3).map { |b| b.to_i(16) }
      end.flatten
    end
   
    # Compress array of r,g,b values to 8bit values ready to send to propeller
    # @param data [Array] - array of decimal r,g,b values
    # @return [Array] - array of 8bit values ready to send to propeller 
    def compress data
      data.map { |v| upscale(v).to_s(2).rjust(12, '0')}.join.scan(/.{8}/).map{ |v| v.to_i(2)}
    end
  
end
