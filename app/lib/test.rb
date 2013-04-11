$LOAD_PATH.unshift(Dir.pwd)
require 'propeller'
t = Propeller::Transmitter.new
t.connect '/dev/rfcomm0'
tab = [["00ff00ff".to_i(16)] * 13 + ["ff0000ff".to_i(16)] * 13 +  ["0000ffff".to_i(16)] * 14]
t.transmit tab
