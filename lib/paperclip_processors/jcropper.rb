module Paperclip
  class Jcropper < Thumbnail
    def transformation_command
      scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)
      trans = ''
      if crop_string?
        trans << " #{crop_string}"
        trans << " -resize \"#{scale}\""
      else
        trans << " -resize \"#{scale}\""
        trans << " -crop \"#{crop}\" +repage" if crop
        trans.sub!('-crop', '-gravity North -crop') # add north gravity
        trans.sub!(/\d+\+\d+"/, '0+0"') # remove calculated offset
      end
      trans << " #{convert_options}" if convert_options?
      puts trans
      trans
    end

    def crop_string
      @attachment.instance.jcropper_crop_string
    end

    def crop_string?
      not crop_string.blank?
    end
  end
end