class JcropperGenerator < Rails::Generator::NamedBase
  attr_accessor :attachment, :migration_name, :style
 
  def initialize(args, options = {})
    super
    raise "Incorrect usage!" unless args.length == 3
    @class_name, @attachment, @style = args[0], args[1], args[2]
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
    "add_crop_variables_for_#{@attachment}_#{@style}_to_#{@class_name.underscore}"
  end
end
