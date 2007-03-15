require 'fileutils'

module RAGE

  module Generators

    #
    # Generates the directory structure for a RAGE application.
    #
    class ApplicationGenerator
      
      #
      # Run the application generator with the given array
      # of command-line arguments.
      #
      def run(args)
        app_path = ARGV.first
        FileUtils.mkdir app_path
        FileUtils.touch File.join(app_path, "Rakefile") # FIXME
        FileUtils.touch File.join(app_path, "README") # FIXME
        FileUtils.mkdir File.join(app_path, "log")
        FileUtils.mkdir File.join(app_path, "script")
      end
      
    end # ApplicationGenerator

  end # end Generators

end # end RAGE
