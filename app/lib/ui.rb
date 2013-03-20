require 'propeller'
require 'green_shoes'

Shoes.app do 
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
  
  args = ARGV.dup
  ARGV.clear
  command = args.shift.strip rescue 'help'

  @propeller = Propeller.new self
  @propeller.run(command, args)
end
