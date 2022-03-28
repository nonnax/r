#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-03-23 14:17:58 +0800
class Object #:nodoc:
  def meta_def(m,&b) #:nodoc:
    (class<<self;self end).send(:define_method,m,&b)
  end
end

module U
  #utils
  module_function
  def compile_path_params(path)
    extra_params = []
    compiled_path = path.gsub(/:\w+/) do |match|
      extra_params << match.gsub(':', '').to_sym
      '([^/?#]+)'
    end
    [/^#{compiled_path}$/, extra_params]
  end
  
  def _render(text, b=binding)
    ERB.new(text).result(b)
  end
  
  def erb t, b=binding, layout: true
    # render template from class_method <t> or file <t> in /views
    # class method templates must be defined the App controller; used by all succeeding controllers
    f, l = [t, :layout].map{|f| File.expand_path("../views/#{f}.erb",__dir__) rescue nil }
    
    template = self.respond_to?(t)?send(t):File.read(f)
    t_layout = self.respond_to?(:layout)?send(:layout):File.read(l)
        
    s=_render(template, b)
    s=_render(t_layout){s}
    s
  rescue 
    "Not Found: #{t}"
  end

  def get_extra_params(route_path:, path_info:)
    path, extra_params=route_path
    path.match(path_info)
    extra_params=extra_params.zip(Regexp.last_match.captures).to_h rescue {}
  end
end

module ClassMethods
  attr_accessor :req, :res
  def apps
    @@apps||=[]  
  end

  %i[GET POST PUT DELETE].each{|v| define_method(v.downcase){|&block| self.code[v]=block }  }
  
  def _call(env)
    @req=Rack::Request.new env
    @res=Rack::Response.new
    @res.headers.merge!( {'Content-type'=>'text/html; charset=UTF-8'} )
    request_method=@req.request_method.to_sym
    params=@req.params
    route = self.apps.detect{|r| [@req.path_info.match?(r.path[0]), !r.code[request_method].nil?].all? }

    extra_params=U.get_extra_params( route_path: route.path, path_info: @req.path_info) rescue {}
    
    body = instance_exec( params.merge!(extra_params), &route.code[request_method] ) rescue nil
    @res.write body
    return @res.finish if body
    [404, {'Content-type'=>'text/html'}, ["Not Found"]]
  end

  def call(env)=dup._call(env)
  def layout = "layout <%= yield %>"
end


def R u
  klass=Class.new {
    extend ClassMethods
    extend U
    meta_def(:code){ @code||={} }
    meta_def(:path){ 
      @path, @extra_params = U.compile_path_params(u) unless [@path, @extra_params].any? 
      [@path, @extra_params]
    }
    meta_def(:inherited){|ch| apps<<ch }
  }
end
