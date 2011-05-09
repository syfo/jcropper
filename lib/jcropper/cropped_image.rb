module JCropper
  class CroppedImage
    attr_reader :original_geometry, :cropped_geometry, :attachment_name, :style_name, :coord_names, :starting_crop, :attachment, :options
    
    def initialize(object, options)
      @object = object
      @options = options
      @attachment_name = object.class.jcropper_defs[:attachment]
      @style_name = object.jcropper_defs[:style]
      @attachment = object.send(attachment_name)  
      @coord_names = {}
      %w(x y w h).each{|v| @coord_names[v.to_sym] = JCropper.jattr(attachment_name, style_name, v)}

      @starting_crop = @coord_names.inject({}) {|h,pair| h.merge({ pair[0] => object.send("#{pair[1].to_s}_was") }) }
    end
    
    ###CRZ these two might get out of date...
    def original_geometry
      if attachment.to_file(:original) and File.exists? attachment.to_file(:original)
        @original_geometry ||= Paperclip::Geometry.from_file(attachment.to_file(:original))
      else
        nil
      end
    end

    def target_geometry
      @target_geometry ||= Paperclip::Geometry.parse(@object.send(attachment_name).styles[style_name.to_sym][:geometry])
    end
        
    def max_crop
      if options[:maintain_aspect_ratio]
        north_center_gravity_max_crop
      else
        [0, 0, original_geometry.width, original_geometry.height]
      end
    end
    
    def north_center_gravity_max_crop
      scale = JCropper.find_bounding_scale([original_geometry.width, original_geometry.height], [target_geometry.width, target_geometry.height])
      final_size = {:width => scale*target_geometry.width, :height => scale*target_geometry.height}
      [(original_geometry.width - final_size[:width]) / 2, 0, final_size[:width], final_size[:height]].map &:to_i
    end
  end
end