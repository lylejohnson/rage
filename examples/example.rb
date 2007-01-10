require 'rage/agent'
require 'rage/platform'

class SummerAgent < RAGE::Agent
  
  def initialize(params={})
    super
  end

end

if __FILE__ == $0
  
  RAGE::Platform.new(:config => "example.yaml").run
  Thread.list.each { |t| t.join if t != Thread.main }
 
end