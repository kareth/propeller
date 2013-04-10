# class used as interface for windows interface, allowing communication with propeller class
class Propeller::Interface
  require 'propeller/windows'

  def initialize args, propeller
    @propeller = propeller
    @windows = Propeller::Windows.new args, self
  end

  # Orders propeller to start processing image selected by user including propeller data generation and preview rendering
  # @param path [String] path to image specified by user
  # @param placement [Hash] pacement hash specified by user, including X offset(x), Y offset(y) and diameter size (s)
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
  # @param path [String] path to processed preview image
  def processed path
    show_preview path
    hide_loader
  end

  # Displays preview of processed preview image stored at path
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
