require 'jcropper'
require 'rails'

module Jcropper
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/jcropper.rake"
    end
  end
end