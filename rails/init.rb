if false
#if RAILS_ENV == 'development'
  require 'active_support' unless defined? ActiveSupport
  require 'active_record' unless defined? ActiveRecord

  ActiveSupport::Dependencies.explicitly_unloadable_constants += [ 'JCropper', 'JCropper::ClassMethods']
  ActiveSupport::Dependencies.load_once_paths.delete lib_path
  ActiveSupport::Dependencies.log_activity = true 

  puts "lib_path::", lib_path, "\n"
  puts "load_paths::", ActiveSupport::Dependencies.load_paths, "\n"
  puts "load_once_paths::", ActiveSupport::Dependencies.load_once_paths, "\n"
end

require 'jcropper.rb'