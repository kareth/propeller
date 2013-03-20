require 'mini_magick'

class Propeller::ImageProcessor
  def initialize
    @angles = 360
    @radius = 60
    @inner_radius = 20
  end

  # Change image from regular rectangular format to angular format
  # @param path [String] path to orginal image
  # @param placement [Hash] hash with info about dimensions and offset
  # @return [String] returns path to processed image
  def process original_path, placement = {}
    @path = new_file_path
    @placement = placement
    @image = MiniMagick::Image.open(original_path)
    do_full_processing
    @image.write(@path)
    @path
  end

  def do_full_processing
    position_and_pad
    depolarize
    skew
    cut_box
    resize
  end

  def position_and_pad
    # PENDING
  end

  def depolarize
    @image.run_command("convert", @image.path, "-virtual-pixel Black -distort DePolar 0", @image.path)
  end

  def skew
    # PENDING
  end

  def cut_box
    # PENDING
  end

  def resize
    # PENDING
  end

  #Ggenerates path to store newly processed file
  def new_file_path
    "#{store_dir}/#{filename}.jpeg"
  end

  # Generates random filename based on current time
  def filename
    Time.now.strftime("%Y_%m_%d_%H%M%S") + [*('A'..'Z')].sample(8).join
  end

  # Directory used to store images
  def store_dir
    File.expand_path "../../tmp/", Pathname(__FILE__).dirname.realpath
  end
end
