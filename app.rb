#!/usr/bin/env ruby
# Id$ nonnax 2022-03-26 11:15:12 +0800
require_relative 'lib/r'

class App < R '/home/:id'
  get do |env|
    @path = 'pato'
    env = "env #{env} #{@path} #{self.apps.map(&:path)}"
    erb :index, binding
  end
  post do
    @path = 'pato'
    t="@param = 'parang PELICAN'"
    # erb :index, binding
  end
  
  # inline-templates must be defined the App controller; used by all succeeding controllers
  
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
  def self.captures
    %{
      Captured
      params: 
      <%= params%>
    }
  end

end

class Index < R '/'
  get{|params| res.redirect '/home/1'}
end

class Next < R '/:id'
  get do |params|
    env="params: #{params}"
    res.redirect "/home/#{params[:id]}"
    erb :xindex, binding # shows erb error message
  end
end

class S < R '/param/:id'
  get do |params|
    p self.methods.sort-Object.methods
    erb :captures, binding
  end
end

