require 'mini_magick'
require 'chunky_png'
require 'propeller/dimensions'

# Main image processor, converting image to matrix of pixels to display on robot
class Propeller::ImageProcessor
  PLACEMENT = {x: 0, y: 0, s: 200} # Default placement hash

  def initialize
    @angles = 360
  end

  # Change image to format readable by propeller display
  # @param original_path [String] path to orginal image
  # @param placement [Hash] hash with info about dimensions and offset
  # @return [Array] matrix of pixels to display by propeller [distance][angle]
  def process original_path, placement
    @original_path = original_path
    @placement = PLACEMENT.merge placement
    (INNER...OUTER).to_a.map{ |radius| compute_radius radius }
  end

  # Get all pixels on the circle of radius 'radius' to display on propeller
  # @param radius [Integer] index of diode to fetch row for
  # @return [Array] array of pixels - one pixel for each angle for given diode
  def compute_radius radius
    angle = Math.atan(Y_DIM/X_DIM) - Math.atan( (Y_DIM - D_DIST * (OUTER - radius)) / X_DIM)
    @image = MiniMagick::Image.open(@original_path)
    crop_square
    rotate angle
    depolarize
    resize
    read_row radius
  end

  # Crops the square part of the image in selected position given on @placement
  # x - offset on x axis, y - offset on y axis, s - diameter of the displayed circle
  def crop_square
    position = "#{@placement[:s]}x#{@placement[:s]}+#{@placement[:x]}+#{@placement[:y]}" # "XDIM x YDIM + OFFX + OFFY"
    @image.run_command("convert", @image.path, "-crop #{position}", @image.path)
  end

  # Rotates the image in order to adjust the corresponding diods offset
  # @param angle [Float] angle in radians. Image is rotated CCW
  def rotate angle
    position = "#{@placement[:s]}x#{@placement[:s]}+#{@placement[:x]}+#{@placement[:y]}"
    @image.run_command("convert", @image.path, "-rotate #{360 - angle}", @image.path)
    @image.run_command("convert", @image.path, "-gravity Center -crop #{position}", @image.path)
  end

  # Decompose image to angular data taking center pixel as rotation axis
  def depolarize
    @image.run_command("convert", @image.path, "-virtual-pixel Black -distort DePolar 0", @image.path)
  end

  # Resize image to dimensions necessary for propeller display, so each pixel will match one led
  # @example For example if propeller takes 360 angles on 40 diods with outer radius 50 (indluding hole) it resizes it to 360x50
  def resize
    @image.resize "#{@angles}x#{OUTER}\!"
  end

  # Reads nth row in image and convert it to array of pixels. Each pixes is represented as hex RGBA
  # @param radius [Integer] Index of pixel row
  def read_row radius
    @image.format('png')
    p = ChunkyPNG::Image.from_io(StringIO.new(@image.to_blob))
    a = (0...p.width).to_a.map{ |x| p[x, radius] }
  end
end
