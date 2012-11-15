require './fireside'
run Rack::Adapter::Camping.new(Fireside)
