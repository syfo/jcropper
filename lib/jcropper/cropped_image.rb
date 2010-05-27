module JCropper
  class CroppedImage
    attr_reader :original_geometry, :cropped_geometry, :attachment_name, :style_name, :coord_names, :starting_crop, :attachment
    
    def initialize(object)
      @object = object
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
      [0, 0, original_geometry.width, original_geometry.height]
    end
  end
end