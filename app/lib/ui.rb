require 'propeller'
require 'green_shoes'

WINDOW_WIDTH = 800
WINDOW_HEIGHT = 500
PREVIEW_WIDTH = 400
PREVIEW_HEIGHT = 400
BACKGROUND = "#eee"

Shoes.app :title => "Awesome Propeller", :width => WINDOW_WIDTH, :height => WINDOW_HEIGHT do 
  # Triggered once user loads another image or change x/y/w/h params
  # @param path [String] path to loaded image
  # @param placement [Hash] hash with x/y/w/h placement info
  def reload_image path, placement = {}
    @propeller.image_loaded path, placement
    show_loader
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
  
  stack :width => PREVIEW_WIDTH+30, :margin => 10 do
    para em "Preview"
    @preview = image "http://lorempixel.com/400/400/nightlife/",
              :width => PREVIEW_WIDTH, :height => PREVIEW_HEIGHT
  end
  
  stack :width => -PREVIEW_WIDTH-30, :margin => 10 do
    para em "Settings"
    
    button "Load image from file" do 
      path = ask_open_file 
      @preview.path = path
      reload_image(path)
    end
    para "or input text to display", :margin_bottom => 0
    @text = edit_line
    flow do
      @pick_color = button "and pick color" do 
        @color = ask_color 
      end
      fill @color
      @color_probe = rect :width => 20, :top => 0, :left => 0
    end
    
    flow do
      @width =  edit_line :width => 60
      para 'px', :width => 20, :margin_top => 5
      strong(para 'x', :width => '40', :align => :center)
      @width.focus
      @height = edit_line :width => 60
      para 'px', :width => 20, :margin_top => 5
    end 
  end
  
  @text.click do
    @text.text = ''
  end
  
  @color_probe.style :top => @pick_color.top, :left => @pick_color.left + 80
  
  args = ARGV.dup
  ARGV.clear
  command = args.shift.strip rescue 'help'

  @propeller = Propeller.new self
  @propeller.run(command, args)
  
end
