require 'mini_magick'

class Propeller::ImageProcessor

  def initialize
    @angles = 360
    @radius = 60
    @inner_radius = 20
  end

  # Change image to format readable by propeller display
  # @param path [String] path to orginal image
  # @param placement [Hash] hash with info about dimensions and offset
  def process original_path, placement = {}
    @placement = placement
    @image = MiniMagick::Image.open(original_path)
    do_full_processing
    @image.write(new_file_path)
    new_file_path
  end

  def do_full_processing
    position_and_pad
    depolarize
    skew
    adjust_density
    cut_box
    resize
  end

  # Converts image to square sized and pads empty space based on offset settings
  def position_and_pad
  end

  # Decompose image to angular data
  def depolarize
    @image.run_command("convert", @image.path, "-virtual-pixel Black -distort DePolar 0", @image.path)
  end

  # Skew image to make it match our repositioned pixels
  def skew
  end

  # Adjusts density of depolarized image
  def adjust_density
  end

  # Cut rectangle out of created image (removing inner radius)
  def cut_box
  end

  # Resize image to dimensions necessary for propeller display, so each pixel will match one led
  def resize
  end

  # Generates path to store newly processed file
  def new_file_path
    @processed_path ||= "#{store_dir}/#{filename}.jpeg"
  end

  # Generates random filename based on current time
  # @example
  #   filename #=> "2013_03_20_144051JILWPERU"
  def filename
    Time.now.strftime("%Y_%m_%d_%H%M%S") + [*('A'..'Z')].sample(8).join
  end

  # Directory used to store images
  def store_dir
    File.expand_path "../../tmp/", Pathname(__FILE__).dirname.realpath
  end
end
