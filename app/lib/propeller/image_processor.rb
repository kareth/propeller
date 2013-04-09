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
    
    pixels.reverse!
    
    # White hole
    pixels << ["ffffffff".to_i(16)]*360
    
    center = radius,radius
    
    commands = [] # Commands buffer
    
    step = radius.to_f / (@outer_radius)
    pixels.each do |circle|
      puts "radius: #{radius}"
      circle.rotate! 180
      circle.each_with_index do |pixel, alfa|
      
        rgba = pixel.to_s(16)
        # Fill color with '0' from left side
        rgba = '0'*(8-rgba.size) + rgba
        
        rad1 = alfa.to_f * Math::PI / 180
        rad2 = (alfa+1).to_f * Math::PI / 180
        start_point = [radius.to_f * Math.sin(rad1) + center[0], radius.to_f * Math.cos(rad1) + center[1]]
        end_point = [radius.to_f * Math.sin(rad2) + center[0], radius.to_f * Math.cos(rad2) + center[1]]
        
        commands << ["fill", "##{rgba}"] # Fill with pixel color
        commands << ["draw", "path 'M #{center.join(',')} L #{start_point.join(',')} A 50,50 0 0,1 #{end_point.join(',')} Z'"] # Draw pixel
        
      end
      
      # Perform commands from buffer
      preview.combine_options do |p|
        commands.each do |command,arg|
          p.send command, arg
        end
      end
      commands.clear
      
      radius -= step
    end
    
    preview.write('preview.png')
    
    File.absolute_path 'preview.png'
  end
  
  def multicolor_preview
    tab = []
    40.times do |i|
      if i.even?
        color1 = "ffff00ff".to_i(16)
        color2 = "00ff00ff".to_i(16)
      else
        color1 = "ff0000ff".to_i(16)
        color2 = "0000ffff".to_i(16)
      end
      tab << [color1]*180 + [color2]*180
    end
    tab
  end
end
