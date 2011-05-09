require 'railtie' if defined?(Rails) and Rails.version.split('.').first.to_i > 2
ROOT = File.join(File.dirname(__FILE__), 'jcropper')
require File.join(ROOT, 'jcropper')
require File.join(ROOT, 'helpers')
require File.join(ROOT, 'cropped_image')
Paperclip.autoload 'Jcropper', File.join(ROOT, '../paperclip_processors/jcropper.rb')
