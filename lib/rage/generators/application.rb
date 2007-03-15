require 'fileutils'

module RAGE

  module Generators

    class ApplicationGenerator
      
      def initialize(args)
        app_path = ARGV.first
        FileUtils.mkdir app_path
        FileUtils.touch File.join(app_path, "Rakefile") # FIXME
        FileUtils.mkdir File.join(app_path, "log")
        FileUtils.mkdir File.join(app_path, "script")
      end
      
    end # Application

  end # end Generators

end # end RAGE
