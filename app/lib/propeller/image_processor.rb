require 'mini_magick'
require 'chunky_png'

class Propeller::ImageProcessor
  X_DIM = 186.8
  Y_DIM = 23

  def initialize
    @angles = 360
    @outer_radius = 60
    @inner_radius = 20
  end

  # Change image to format readable by propeller display
  # @param path [String] path to orginal image
  # @param placement [Hash] hash with info about dimensions and offset
  def process original_path, placement = {x: 0, y: 0, s: 100}
    @original_path = original_path
    @placement = placement
    [@outer_radius..@inner_radius].map{ |radius| compute_radius radius }
  end

  def do_full_processing
  end

  # get all pixels on the circle of radius radius
  def compute_radius radius
    angle = Math.atan(Y_DIM/X_DIM) - Math.atan( (Y_DIM - 4.0 * (@outer_radius - radius)) / X_DIM)
    @image = MiniMagick::Image.open(@original_path)
    crop_square
    rotate angle
    depolarize
    resize
    read_row
  end

  # Cuts the square part of the image in selected position
  def crop_square
    position = @placement[:s] + "x" + @placement[:s] + "+" + @placement[:x] + "+" + @placement[:y]
    @image.run_command("convert", @image.path, "-crop #{position}", @image.path)
  end

  # rotate
  def rotate angle
    @image.run_command("convert", @image.path, "-rotate #{360 - angle}", @image.path)
    @image.run_command("convert", @image.path, "-gravity Center -crop #{@placement[:s]}x#{@placement[:s]}+0+0", @image.path)
    # TODO Crop
  end

  # Decompose image to angular data
  def depolarize
    @image.run_command("convert", @image.path, "-virtual-pixel Black -distort DePolar 0", @image.path)
  end

  # Resize image to dimensions necessary for propeller display, so each pixel will match one led
  def resize
    @image.resize "#{@angles}x#{@outer_radius}\!"
  end

  def read_row
    @image.format('png')
    p = ChunkyPNG::Image.from_io(StringIO.new(i.to_blob))
    [0..p.width].map{ |x| p[x, radius] }
  end
end
