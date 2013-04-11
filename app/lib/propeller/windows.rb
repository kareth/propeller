require 'Qt4'
require 'propeller/rectangle'

# Class responsible for displaying windows using QT
class Propeller::Windows < Qt::Application
  slots :change_image, :change_text, :pick_color, 
        :connect_device, :send_data

  WINDOW_WIDTH = 650
  WINDOW_HEIGHT = 500
  PREVIEW_WIDTH = 400
  PREVIEW_HEIGHT = 400
  MARGIN_BIG = 20
  MARGIN = 10
  BACKGROUND = "#eeeeee"
  IMAGE_PLACEHOLDER = File.expand_path("../../spec/assets/test.jpg", Pathname(__FILE__).dirname.realpath)

  def initialize args, interface
    super(args)
    @interface = interface
    init_gui_elements
    @image_dialog = Qt::FileDialog.new
    @image_dialog.setFileMode Qt::FileDialog::ExistingFile
    @image_dialog.setNameFilter "Images (*.png *.jpeg *.jpg *.gif)"
  end

  # Loads image to preview part
  # @param path - Path to preview image
  def load_preview path
    pixmap = Qt::Pixmap.new path
    pixmap = pixmap.scaled Qt::Size.new(PREVIEW_WIDTH,PREVIEW_HEIGHT)

    @image.pixmap = pixmap
  end

  private
    # Sets GUI interface
    def init_gui_elements
      @window = Qt::Widget.new
      @window.resize WINDOW_WIDTH,WINDOW_HEIGHT
      @window.setWindowTitle 'Awesome Propeller!'
      center_window
      
      main_layout = Qt::HBoxLayout.new

      layout = Qt::VBoxLayout.new @window
      layout.addLayout main_layout
    
      # Preview part
      preview_layout = Qt::VBoxLayout.new
      preview_layout.setAlignment Qt::AlignTop
      main_layout.addLayout preview_layout

      # Preview title
      preview_label = Qt::Label.new 'Preview'
      preview_label.setStyleSheet "QLabel { margin-bottom: #{MARGIN}px; font-weight: bold; }"
      preview_layout.addWidget preview_label

      # Preview image
      @image = Qt::Label.new
      preview_layout.addWidget @image
      load_preview IMAGE_PLACEHOLDER

      # Settings part
      settings_layout = Qt::VBoxLayout.new
      settings_layout.setAlignment Qt::AlignTop
      main_layout.addLayout settings_layout

      # Settings title
      settings_label = Qt::Label.new 'Settings'
      settings_label.setStyleSheet "QLabel { margin-bottom: #{MARGIN}px; font-weight: bold; }"
      settings_layout.addWidget settings_label

      # Propeller connection
#      propeller_label = Qt::Label.new "Device"
#      propeller_label.setStyleSheet "QLabel { font-style: italic; font-size: 0.9em; margin-bottom: #{MARGIN}px; }"
#      settings_layout.addWidget propeller_label

      device_layout = Qt::HBoxLayout.new 
      port_label = Qt::Label.new "Device port"
      @device_port = Qt::LineEdit.new
      device_layout.addWidget port_label
      device_layout.addWidget @device_port
      
      settings_layout.addLayout device_layout
      
      @connect_button = Qt::PushButton.new "Connect", @window
      Qt::Object.connect(@connect_button, SIGNAL(:clicked), self, SLOT(:connect_device))
      settings_layout.addWidget @connect_button
      
      # Offset
      offset_label = Qt::Label.new "Offset"
      offset_label.setStyleSheet "QLabel { font-style: italic; font-size: 0.9em; margin-bottom: #{MARGIN}px; }"
      settings_layout.addWidget offset_label
      # x
      x_layout = Qt::HBoxLayout.new
      x_layout.addWidget Qt::Label.new "Offset X"
      @x_offset = Qt::LineEdit.new
      x_layout.addWidget @x_offset
      x_layout.addWidget Qt::Label.new "px"
      settings_layout.addLayout x_layout
      # y
      y_layout = Qt::HBoxLayout.new
      y_layout.addWidget Qt::Label.new "Offset Y"
      @y_offset = Qt::LineEdit.new
      y_layout.addWidget @y_offset
      y_layout.addWidget Qt::Label.new "px"
      settings_layout.addLayout y_layout
      
      # Radius
      diameter_layout = Qt::HBoxLayout.new
      diameter_layout.addWidget Qt::Label.new "Diameter"
      @diameter = Qt::LineEdit.new
      diameter_layout.addWidget @diameter
      settings_layout.addLayout diameter_layout
      
      # Angles
      angles_layout = Qt::HBoxLayout.new
      angles_layout.addWidget Qt::Label.new "Angles number"
      @angles = Qt::LineEdit.new
      angles_layout.addWidget @angles
      settings_layout.addLayout angles_layout
      


      # Source
#      source_label = Qt::Label.new 'Source'
#      source_label.setStyleSheet "QLabel { font-style: italic; font-size: 0.9em; margin: #{MARGIN}px 0; }"
#      settings_layout.addWidget source_label

      # Image
      @image_button = Qt::PushButton.new 'Load image from file', @window
      Qt::Object.connect(@image_button, SIGNAL(:clicked), self, SLOT(:change_image))
      settings_layout.addWidget @image_button


      # Text input
      text_case_label = Qt::Label.new('or input text to display')
      text_case_label.setStyleSheet "QLabel { margin-top: #{MARGIN_BIG}px; }"
      settings_layout.addWidget text_case_label
      @text_input = Qt::LineEdit.new @window
      settings_layout.addWidget @text_input

      # Pick color
      color_layout = Qt::HBoxLayout.new
      @color_button = Qt::PushButton.new 'and pick color'
      Qt::Object.connect(@color_button, SIGNAL(:clicked), self, SLOT(:pick_color))
      color_layout.addWidget(@color_button)
      # Color probe
      @color_probe = Rectangle.new @window
      color_layout.addWidget @color_probe
      settings_layout.addLayout color_layout

      # Load text
      @text_button = Qt::PushButton.new 'Load text', @window
      Qt::Object.connect(@text_button, SIGNAL(:clicked), self, SLOT(:change_text))
      settings_layout.addWidget @text_button
      
      # Send to propeller
      @send_button = Qt::PushButton.new 'Send to propeller', @window
      Qt::Object.connect(@send_button, SIGNAL(:clicked), self, SLOT(:send_data))
      layout.addWidget @send_button

      @window.show
    end

    # Centers window main window
    def center_window
      desktop = Qt::DesktopWidget.new
      x = (desktop.width - WINDOW_WIDTH) / 2
      y = (desktop.height - WINDOW_HEIGHT) / 2
      @window.move x, y
    end
    
    # Triggered on change image button click
    def change_image
      path = @image_dialog.getOpenFileName
      params = {}
      params[:y] = @y_offset.text.to_i unless @y_offset.text.empty?
      params[:x] = @x_offset.text.to_i unless @x_offset.text.empty?
      params[:s] = @diameter.text.to_i unless @diameter.text.empty?
      params[:a] = @angles.text.to_i unless @angles.text.empty?
      @interface.reload_image path, params
      #load_preview path
    end

    # Triggered on load text button click
    def change_text
      @interface.reload_text @text_input.text
    end

    # Open dialog to choose text color
    def pick_color
      dialog = Qt::ColorDialog.new @window
      color = dialog.getColor
      @color_probe.update_color color
    end
    
    # Triggered on connect device button click   
    def connect_device
      @interface.connect_device @device_port.text
    end
    
    # Triggered on send data button click
    def send_data
      @interface.send_data
    end
    
end
