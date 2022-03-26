#!/usr/bin/env ruby
# frozen_string_literal: true

# Id$ nonnax 2022-03-23 14:17:58 +0800
class Object #:nodoc:
  def meta_def(m,&b) #:nodoc:
    (class<<self;self end).send(:define_method,m,&b)
  end
end

def erb t, b=bindimg
  template=send(t.to_sym)
  ERB.new(template).result(b)
end

def compile_path_params(path)
    extra_params = []
    compiled_path = path.gsub(/:\w+/) do |match|
      extra_params << match.gsub(':', '').to_sym
      '([^/?#]+)'
    end
    [/^#{compiled_path}$/, extra_params]
end

@apps=[]
@routes = Hash.new []

module ClassMethods
  extend self
  def _call(env)
    @req=Rack::Request.new env
    @res=Rack::Response.new
    extra_params={}
    route = self
            .routes[@req.request_method]
            .detect{|r| @req.path_info.match(r[:path_regexp])}
            .tap{ |r| extra_params=r[:extra_params].zip(Regexp.last_match&.captures).to_h rescue {} }
    
    params = @req.params.merge(extra_params)

    status = @res.status
    headers = @res.headers.empty? ? {'Content-type'=>'text/html; charset=UTF-8'} : @res.headers
    body = instance_exec params, &route[:code] rescue nil
    
    return [status, headers, [body]] unless body.nil? 
    self.not_found 
  end
  
  def call(env)
    dup._call(env)
  end
  
  def not_found
    [404, {'Content-type'=>'text/html; charset=UTF-8'}, ["Not Found"]]
  end
  
  %i[get post].each do |verb|
    define_method(verb) do |&block|
      r={ path: self.path, path_regexp: nil, extra_params: nil , code: block}
      r[:path_regexp], r[:extra_params]=compile_path_params(self.path)
            
      self.routes[verb.upcase] << r    
    end
  end  
end

def R u
  apps=@apps
  routes=@routes
  klass=Class.new {
    extend ClassMethods
    meta_def(:routes){routes}
    meta_def(:path){u}
    meta_def(:inherited){|ch| 
      apps << ch
    }
  }
end
