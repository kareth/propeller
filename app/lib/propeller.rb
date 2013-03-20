class Propeller
  def self.start command, args
    HelloWorld.say_it_shoes
    puts "Command: '#{command}'"
    puts "Args: '#{args.join(", ")}'"
  end
end
