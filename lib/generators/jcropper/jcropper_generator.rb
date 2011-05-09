require 'rails/generators/active_record'

class JcropperGenerator < ActiveRecord::Generators::Base
  desc "Create a migration to add jcropper-specific fields to your model."
 
#  argument :model, :required => true, :type => :string, :desc => "The name of the ActiveRecord model", :banner => "<Model>"
  argument :attachment, :required => true, :type => :string, :desc => "The name of the paperclip attachment", :banner => "<attachment>"
  argument :style, :required => true, :type => :string, :desc => "", :banner => "<style>"

  def self.source_root
    @source_root ||= File.expand_path('../../../../generators/jcropper/templates', __FILE__)
  end

  def generate_migration
    migration_template "jcropper_migration.rb.erb", "db/migrate/#{migration_file_name}"
  end

  protected

  def banner
    "<Model>"
  end

  def migration_name
    "add_crop_variables_for_#{attachment}_#{style}_to_#{name.underscore}"
  end

  def migration_file_name
    "#{migration_name}.rb"
  end

  def migration_class_name
    migration_name.camelize
  end
end
