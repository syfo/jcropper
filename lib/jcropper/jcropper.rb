module JCropper
  module ClassMethods
    def js_crop(attachment, options = {})
      raise "jcropper requires attachment to be of type Paperclip::Attachment" if self.attachment_definitions[attachment.to_sym].nil?
      require File.join(ROOT, '../paperclip_processors/jcropper.rb')
      
      options[:attachment] = attachment = attachment.to_s
      options[:lock_aspect] ||= true
      
      x, y, w, h = "#{attachment}_crop_x", "#{attachment}_crop_y", "#{attachment}_crop_w", "#{attachment}_crop_h" 

      class_exec(options) do |options|
        write_inheritable_attribute :jcropper_options, options.dup
        class_inheritable_reader :jcropper_options
        
        attr_accessor :jcropper_should_reprocess
        before_save :jcropper_check_for_reprocess
        after_save :jcropper_reprocess
        
        def jcropper_reprocess
          send(self.class.jcropper_options[:attachment]).reprocess! if @jcropper_should_reprocess
        end
      end

      to_eval = <<-TO_EVAL
        def jcropper_check_for_reprocess
          @jcropper_should_reprocess ||= !(changed & %w(#{x} #{y} #{w} #{h})).empty?
          return true
        end

        def jcropper_crop_string
          if not [#{x}, #{y}, #{w}, #{h}].all?{|v| v.nil? or v.zero?}
            "-crop \#{#{w}}x\#{#{h}}+\#{#{x}}+\#{#{y}}"
          else
            ""
          end
        end
      TO_EVAL
      class_eval to_eval
    end
  end
  
  module InstanceMethods
  end
end

class ActiveRecord::Base
  include JCropper::InstanceMethods
  extend JCropper::ClassMethods
end