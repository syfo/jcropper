module JCropper
  module ClassMethods
    def jcrop(attachment, style)
      raise "jcropper requires attachment to be of type Paperclip::Attachment" if self.attachment_definitions[attachment.to_sym].nil?
      
      class_exec(attachment, style) do |attachment, style|
        attr_reader :cropped_image
        write_inheritable_hash :jcropper_defs, {:attachment => attachment, :style => style} 
        class_inheritable_reader :jcropper_defs

        attr_accessor :jcropper_should_reprocess
        before_save :jcropper_check_for_reprocess
        after_save :jcropper_reprocess
        
        ###CRZ - alias chain this
        def after_initialize
          @cropped_image = CroppedImage.new(self)
        end
        
        def jcropper_reprocess
          cropped_image.attachment.reprocess! if @jcropper_should_reprocess
        end

        def jcropper_is_cropped?
          jcropper_coords.all?{|v| v.nil? or v.zero?} or 
          (jcropper_coords[0] == 0 and 
           jcropper_coords[1] == 0 and 
           jcropper_coords[2] == cropped_image.original_geometry.width and
           jcropper_coords[3] == cropped_image.original_geometry.height
           )
        end
      end

      x, y, w, h = [:x, :y, :w, :h].map{|coord| JCropper.jattr(attachment, style, coord) }
      to_eval = <<-TO_EVAL
        def jcropper_check_for_reprocess
          @jcropper_should_reprocess ||= !(changed & %w(#{x} #{y} #{w} #{h})).empty?
          return true
        end

        def jcropper_coords
          [#{x}, #{y}, #{w}, #{h}]
        end

        def jcropper_crop_string
          if not jcropper_coords.all?{|v| v.nil? or v.zero?}
            "-crop \#{#{w}}x\#{#{h}}+\#{#{x}}+\#{#{y}}"
          else
            ""
          end
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