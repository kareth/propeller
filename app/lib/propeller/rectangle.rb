# class userd to generate rectangle for colorPicker
class Rectangle < Qt::Widget

  attr_writer :color

  def initialize parent = nil, color = nil
    super(parent)
    @color = color || Qt::Color.new(0,0,0)
    update_color
    setAutoFillBackground true
  end

  def update_color color=nil
    @color = color unless color.nil?
    setPalette Qt::Palette.new @color
  end

  def paintEvent event
  end
end
