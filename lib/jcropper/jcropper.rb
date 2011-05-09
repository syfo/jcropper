module JCropper
  def self.find_bounding_scale(container, to_contain)
    to_contain_aspect = to_contain[0].to_f / to_contain[1]
    container_aspect = container[0].to_f / container[1]

    if to_contain_aspect > container_aspect
      return (container[0].to_f / to_contain[0]);
    else
      return (container[1].to_f / to_contain[1]);
    end
  end
  
  module ClassMethods
    def jcrop(attachment, style, options = {})
      raise "jcropper requires attachment to be of type Paperclip::Attachment" if self.attachment_definitions[attachment.to_sym].nil?
      
      attr_reader :cropped_image
      write_inheritable_hash :jcropper_defs, {:attachment => attachment, :style => style} 
      class_inheritable_reader :jcropper_defs
      attr_accessor :jcropper_should_reprocess
      before_save :jcropper_normalize_crop, :jcropper_check_for_reprocess
      after_save :jcropper_reprocess

      x, y, w, h = [:x, :y, :w, :h].map{|coord| JCropper.jattr(attachment, style, coord) }
      if defined?(Rails) and Rails.version.split('.').first.to_i > 2
        to_eval = <<-TO_EVAL
          after_initialize :jcropper_initialize
          def jcropper_initialize
            @cropped_image = CroppedImage.new(self, #{options.to_hash})
          end
        TO_EVAL
      else
        to_eval = <<-TO_EVAL
          ###CRZ - alias chain this
          def after_initialize
            @cropped_image = CroppedImage.new(self, #{options.to_hash})
          end
        TO_EVAL
      end        

      to_eval += <<-TO_EVAL
        def jcropper_reprocess
          cropped_image.attachment.reprocess! if @jcropper_should_reprocess
        end

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