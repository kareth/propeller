# QT widget used to generate rectangle for colorPicker
class Rectangle < Qt::Widget
  attr_writer :color

  # TODO yard
  # @param parent [?]
  # @param color [Color] color to display on preview
  def initialize parent = nil, color = nil
    super(parent)
    @color = color || Qt::Color.new(0,0,0)
    update_color
    setAutoFillBackground true
  end

  # TODO yard
  # @param color [Color]
  def update_color color=nil
    @color = color unless color.nil?
    setPalette Qt::Palette.new @color
  end

  # TODO yard
  # @param event []
  def paintEvent event
  end
end
