require 'webrick/httpserver'
require 'camping'
require 'camping/webrick'

Camping.goes :Dashboard

module Dashboard::Controllers
  
  class Index < R '/'
    def get
      render :index
    end
  end
  
end

module Dashboard::Views
  
  def layout
    html do
      head do
        style :type => "text/css" do
          "table {margin-left: 20px; margin-right: 20px; border: thin solid black; border-collapse: collapse;} " +
          "td, th {border: thin dotted gray; padding: 5px;} th {background-color: #cc6600;} " +
          ".cellcolor {background-color: #fcba7a;}"
        end
        title { "RAGE" }
      end
      body { self << yield }
    end
  end
  
  def index
    h1 "Agents"
    table do
      tr do
        th 'Name'
        th 'State'
      end
      colored = false
      RAGE::Platform.instance.ams.each_agent do |agent_desc|
        tr :class => colored ? "cellcolor" : "" do
          td agent_desc.name
          td agent_desc.state.to_s
          colored = !colored
        end
      end
    end
  end
  
end

module RAGE
  module Web
    class Server < WEBrick::HTTPServer
      
      def initialize
        super(:BindAddress => "0.0.0.0", :Port => 3301)
        mount "/", WEBrick::CampingHandler, Dashboard
      end
      
    end
  end
end

