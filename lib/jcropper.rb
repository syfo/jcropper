require 'railtie' if defined?(Rails) and Rails.version.split('.').first.to_i > 2
root = File.join(File.dirname(__FILE__), 'jcropper')
require File.join(root, 'jcropper')
require File.join(root, 'helpers')
require File.join(root, 'cropped_image')

#Paperclip.autoload 'Jcropper', File.join(root, '../paperclip_processors/jcropper.rb')
require File.join(root, '../paperclip_processors/jcropper.rb')
