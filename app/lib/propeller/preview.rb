# Class userd to generate preview based on propeller data
class Preview
  def initialize
  end

  # Generates preview image based on propeller data
  # @param pixels [Array] Matrix of pixels generated to be displayed on robot
  # @param radius [Integer] Size of output image
  # @return [String] Absolute path to preview image
  def generate array, radius=200
    bg_path = File.expand_path("../../assets/preview_bg.png", Pathname(__FILE__).dirname.realpath)
    preview = MiniMagick::Image.open(bg_path)

    pixels = array.clone
    
    pixels.reverse!

    # White hole
    pixels << ["ffffffff".to_i(16)]*360

    center = radius,radius
    commands = [] # Commands buffer

    step = radius.to_f / OUTER
    pixels.each do |circle|
      puts "radius: #{radius}"
      circle.rotate! 180
      circle.each_with_index do |pixel, alfa|

        rgba = pixel.to_s(16).rjust 8, '0'
        # Fill color with '0' from left side

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

  # Method used to generate some stripped pattern
  # @note this method is not used anywhere, but maybe useful later on
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
