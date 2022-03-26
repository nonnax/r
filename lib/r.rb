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

@apps=[]
@routes = Hash.new []

module ClassMethods
  extend self
  def _call(env)
    @req=Rack::Request.new env
    @res=Rack::Response.new

    route = self
            .routes[@req.request_method]
            .detect{|r| @req.path_info.match(Regexp.new r[:path]) }
    body=instance_exec env, &route[:code]
    status = @res.status
    status = 404 unless body
    headers = {'Content-type'=>'text/html'}
    headers = @res.headers unless @res.headers.empty?
    [status, headers, [body]]
  end
  def call(env)
    dup._call(env)
  end  
  def get &block
    r={ path: path.first , code: block}
    self.routes[:GET]<<r
  end
  def post &block
    r={ path: path.first, code: block}
    self.routes[:POST]<<r
  end
end

def R *u
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
