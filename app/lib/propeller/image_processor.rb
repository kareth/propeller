require 'mini_magick'
require 'chunky_png'

class Propeller::ImageProcessor
  X_DIM = 186.8
  Y_DIM = 23.0

  def initialize
    @angles = 360
    @outer_radius = 60
    @inner_radius = 20
  end

  # Change image to format readable by propeller display
  # @param path [String] path to orginal image
  # @param placement [Hash] hash with info about dimensions and offset
  def process original_path, placement
    @original_path = original_path
    @placement = placement
    fill_placement
    res = (@inner_radius...@outer_radius).to_a.map{ |radius| compute_radius radius }
    generate_preview res
#    generate_preview multicolor_preview
  end

  def fill_placement
    @placement[:s] ||= 200
    @placement[:x] ||= 0
    @placement[:y] ||= 0
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
    read_row radius
  end

  # Cuts the square part of the image in selected position
  def crop_square
    p @placement
    position = "#{@placement[:s]}x#{@placement[:s]}+#{@placement[:x]}+#{@placement[:y]}"
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

  def read_row radius
    @image.format('png')
    p = ChunkyPNG::Image.from_io(StringIO.new(@image.to_blob))
    a = (0...p.width).to_a.map{ |x| p[x, radius] }
    p a[1..10]
    a
  end
  
  def generate_preview pixels, radius=200
    bg_path = File.expand_path("../../assets/preview_bg.png", Pathname(__FILE__).dirname.realpath)
    preview = MiniMagick::Image.open(bg_path)
    
    center = radius,radius
    
    step = radius.to_f / (@outer_radius)
    pixels.each do |circle|
      puts "radius: #{radius}"
      circle.each_with_index do |pixel, alfa|
        rgba = pixel.to_s(16)
        rgba = '0'*(8-rgba.size) + rgba
        # puts "color: #{rgba}, alfa: #{alfa}"
        start_point = [radius.to_f * Math.sin(alfa) + center[0], radius.to_f * Math.cos(alfa) + center[1]]
        end_point = [radius.to_f * Math.sin(alfa+1) + center[0], radius.to_f * Math.cos(alfa+1) + center[1]]
        preview.combine_options do |p|
          p.fill "##{rgba}"
          p.draw "path 'M #{center.join(',')} L #{start_point.join(',')} A 50,50 0 0,1 #{end_point.join(',')} Z'"        
        end
      end
      radius -= step
    end
    preview.combine_options do |p|
      p.fill "#ffffffff"
      p.draw "translate #{center.join(',')} circle 0,0 #{@radius},0"        
    end
    
    preview.write('preview.png')
  end
  
  def multicolor_preview
    tab = []
    40.times do |i|
      color = if i.even? then "ffff00ff".to_i(16) else "ff0000ff".to_i(16) end
      tab << [color]*360
    end
    tab
  end
end
