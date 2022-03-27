#!/usr/bin/env ruby
# Id$ nonnax 2022-03-26 11:15:12 +0800
require_relative 'lib/r'

class App < R '/home/(\d+)'
  get do |env|
    @path = 'pato'
    "env #{env} #{@path}"
    erb :index, binding
  end
  post do
    @path = 'pato'
    t="@param = 'parang PELICAN'"
    # erb :index, binding
  end
end

class Next < R '/:id'
  get do |params|
    @res.status=300
    # @res.headers.merge!({'Content-type'=>'application/json'})
    p "params: #{params}"
    @res.redirect "/home/#{params[:id]}"
  end
end

#templates 
def index
  %{
    response env: 
    <%= env%>
  }
end

