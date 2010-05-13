class JCropperGenerator < Rails::Generator::NamedBase
  attr_accessor :attachment, :migration_name
 
  def initialize(args, options = {})
    super
    @class_name, @attachment = args[0], args[1]
  end
 
  def manifest    
    file_name = generate_file_name
    @migration_name = file_name.camelize
    record do |m|
      m.migration_template "jcropper_migration.rb.erb", File.join('db', 'migrate'), :migration_file_name => file_name
    end
  end 
  
  private 
  
  def generate_file_name
    "add_crop_variables_for_#{@attachment}_to_#{@class_name.underscore}"
  end
end
