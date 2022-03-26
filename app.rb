#!/usr/bin/env ruby
# Id$ nonnax 2022-03-26 11:15:12 +0800
require_relative 'lib/r'

class App < R '/home/(\d+)'
  get do |env|
    @path = 'pato'
    erb :index, binding
  end
  post do
    @path = 'pato'
    t="@param = 'parang PELICAN'"
    erb :index, binding
  end
end

#templates 
def index
  %{
    response env: 
    <%= env%>
  }
end

