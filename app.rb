#!/usr/bin/env ruby
# Id$ nonnax 2022-03-26 11:15:12 +0800
require_relative 'lib/r'

class App < R '/home/:id'
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
  #templates 
  def self.index
    %{
      response env: 
      <%= env%>
    }
  end
  def self.layout
    %q{
      Default Layout
      <%= yield %>
    }
  end
end

class Next < R '/:id'
  get do |params|
    # @res.status=300
    # @res.headers.merge!({'Content-type'=>'application/json'})
    env="params: #{params}"
    res.redirect "/home/#{params[:id]}"
    erb :xindex, binding
  end
end

class S < R '/param/:id'
  get do |params|
    erb :captures, binding
  end
end

def captures
  %{
    params: 
    <%= params%>
  }
end
