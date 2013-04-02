require 'propeller'
require 'green_shoes'

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 500
PREVIEW_WIDTH = 400
PREVIEW_HEIGHT = 400
BACKGROUND = "#eeeeee"

Shoes.app :title => "Awesome Propeller", :width => WINDOW_WIDTH, :height => WINDOW_HEIGHT do 
  # Triggered once user loads another image or change x/y/w/h params
  # @param path [String] path to loaded image
  # @param placement [Hash] hash with x/y/w/h placement info
  def reload_image path, placement = {}
    unless path.nil?
      @propeller.process_image path, placement
      show_loader
    end
  end
  
  def reload_text text, color 
    @propeller.process_text text, color
    show_loader
  end
  
  def reload_preview
    if @text.text.empty?
      reload_image @preview.path, { :top => @offset_top.text, :left => @offset_left.text }
    else
      reload_text @text.text, @color
    end
  end

  # Shows preview and unlocks UI actions
  # @param path [String] path to processed image
  def processed path
    show_preview path
    hide_loader
  end

  # Displays preview of processed image stored at path
  # @param path [String] path to image (processed for propeller)
  def show_preview path
    @preview.clear
    @preview.remove
    @preview_box.append do
      @preview = image path, :width => 400, :height => 400
    end
  end

  # Shows loading animation and blocks UI
  def show_loader
  end

  # Hides loading animation and unlocks UI
  def hide_loader
  end

  # Hides the interface
  def hide
  end

  # Shows the interface
  def show
  end
  
  background BACKGROUND
  @color = "#000000"
  
  @preview_box = stack :width => PREVIEW_WIDTH+30, :margin => 10 do
    para em("Preview"), :size => 16
    @preview = image File.expand_path("../spec/assets/test.jpg", Pathname(__FILE__).dirname.realpath),
              :width => PREVIEW_WIDTH, :height => PREVIEW_HEIGHT
  end
  
  @settings = stack :width => -PREVIEW_WIDTH-30, :margin => 10 do
    para em("Settings"), :size => 16
    
    para strong("Source"), :size => 10
    
    button "Load image from file" do 
      path = ask_open_file 
      reload_image path
    end
    
    para "or input text to display", :margin_bottom => 0
    @text = edit_line
    flow do
      @color_probe = rect :width => 20, :top => 198, :left => PREVIEW_WIDTH+150
      @pick_color = button "and pick color" do 
        @color = ask_color
        @color_probe.style :fill => @color
      end
    end
    
    para strong("Offset"), :size => 10, :margin_top => 20
    
    flow do
      para 'Left', :width => 40, :margin_top => 5
      @offset_left =  edit_line :width => 60
      para 'px', :width => 20, :margin_top => 5
    end
    flow do
      para 'Top', :width => 40, :margin_top => 5
      @offset_top = edit_line :width => 60
      para 'px', :width => 20, :margin_top => 5
    end
    
    button "Reload preview", :margin_top => 60 do 
      reload_preview
    end
      
  end
  
  args = ARGV.dup
  ARGV.clear
  command = args.shift.strip rescue 'help'

  @propeller = Propeller.new self
  @propeller.run(command, args)
  
end
