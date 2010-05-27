module JCropper
  module ClassMethods
    def jcrop(attachment, style)
      raise "jcropper requires attachment to be of type Paperclip::Attachment" if self.attachment_definitions[attachment.to_sym].nil?
      
      class_exec(attachment, style) do |attachment, style|
        attr_reader :cropped_image
        write_inheritable_hash :jcropper_defs, {:attachment => attachment, :style => style} 
        class_inheritable_reader :jcropper_defs

        attr_accessor :jcropper_should_reprocess
        before_save :jcropper_normalize_crop, :jcropper_check_for_reprocess
        after_save :jcropper_reprocess
        
        ###CRZ - alias chain this
        def after_initialize
          @cropped_image = CroppedImage.new(self)
        end
        
        def jcropper_reprocess
          cropped_image.attachment.reprocess! if @jcropper_should_reprocess
        end
      end

      x, y, w, h = [:x, :y, :w, :h].map{|coord| JCropper.jattr(attachment, style, coord) }
      to_eval = <<-TO_EVAL
        def jcropper_check_for_reprocess
          @jcropper_should_reprocess ||= !(changed & %w(#{x} #{y} #{w} #{h})).empty?
          true
        end

        def jcropper_coords
          [#{x}, #{y}, #{w}, #{h}]
        end
        
        def jcropper_needs_crop?
          cropped_image and cropped_image.original_geometry and (#{w} == 0 or #{h} == 0)
        end

        def jcropper_normalize_crop
          self.#{x}, self.#{y}, self.#{w}, self.#{h} = *cropped_image.max_crop if jcropper_needs_crop?
          true
        end

        def jcropper_crop_string
          "-crop \#{#{w}}x\#{#{h}}+\#{#{x}}+\#{#{y}}"
        end
      TO_EVAL
      class_eval to_eval
    end
  end
  
  def self.jattr(attachment, style, coord)
    "#{attachment}_#{style}_crop_#{coord}"
  end
  
  module InstanceMethods
  end
end

class ActiveRecord::Base
  include JCropper::InstanceMethods
  extend JCropper::ClassMethods
end