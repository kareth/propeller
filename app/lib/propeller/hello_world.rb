#require 'green_shoes'

class Propeller::HelloWorld
  def self.say_it
    puts "hello world!"
  end

  def self.say_it_shoes
    Shoes.app(:title => "Awesome propeller", :width => 600, :height => 400) do
      stack :margin => 10 do
        button "Start propeller" do
          alert "Hello World!"
        end
      end
    end
  end
end
