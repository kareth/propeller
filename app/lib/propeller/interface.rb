class Propeller::Interface
  require 'propeller/windows'

  def initialize args, propeller
    @propeller = propeller
    @windows = Propeller::Windows.new args, self
  end

  def reload_image path, placement = {}
    show_loader
    @propeller.process_image path, placement unless path.nil?
  end

  # pending
  def reload_text text, color
    show_loader
    @propeller.process_text text, color
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
    @windows.load_preview path
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
    @windows.exec
  end
end
