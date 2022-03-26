#!/usr/bin/env ruby
# Id$ nonnax 2022-03-26 11:15:12 +0800
require_relative 'lib/r'

class App < R '/home/:id'
  get do |env|
    @path = 'pato'
    # @res.redirect 'https://myflixer.to'
    erb :index, binding
  end
end

class S < R '/param/:id'
  get do |params|
    erb :captures, binding
  end
end
#templates 
def index
  %{
    response env: 
    <%= env%>
  }
end

def captures
  %{
    params: 
    <%= params%>
  }
end
