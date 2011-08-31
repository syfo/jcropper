module JCropper 
  module Helpers
    def croppable_image(object_and_name, attachment, style, options = {})
      object, name = split_object_and_name(object_and_name)
      options[:view_size] = {:width => options.delete(:width), :height => options.delete(:height)} if options[:width] and options[:height]
      return unless options = parse_options(object, options)

      ###CRZ - duplicated in JS!
      view_scale = JCropper.find_bounding_scale([options[:view_size][:width], options[:view_size][:height]],
                    [options[:original_geometry][:width], options[:original_geometry][:height]])

      scaled_img_dims = {:width => options[:original_geometry][:width]*view_scale, :height => options[:original_geometry][:height]*view_scale}
      s = "<div class='#{options[:css_prefix]}'>#{image_tag(object.send(attachment).url, scaled_img_dims.merge(:id => options[:id]))}</div>" + "\n"
      s += hidden_field_tag("#{name}[#{@js_cropper_c_i.coord_names[:x]}]", @js_cropper_c_i.starting_crop[:x], :id => @js_cropper_c_i.coord_names[:x]) + "\n"
      s += hidden_field_tag("#{name}[#{@js_cropper_c_i.coord_names[:y]}]", @js_cropper_c_i.starting_crop[:y], :id => @js_cropper_c_i.coord_names[:y]) + "\n"
      s += hidden_field_tag("#{name}[#{@js_cropper_c_i.coord_names[:w]}]", @js_cropper_c_i.starting_crop[:w], :id => @js_cropper_c_i.coord_names[:w]) + "\n"
      s += hidden_field_tag("#{name}[#{@js_cropper_c_i.coord_names[:h]}]", @js_cropper_c_i.starting_crop[:h], :id => @js_cropper_c_i.coord_names[:h]) + "\n"
      s += <<-JS
        <script type="text/javascript">
          #{options[:js_object]} = new CroppedImage('.#{options[:css_prefix]} img',
            $.extend(
              #{camelize_keys(options).to_json},
              {
                originalGeometry: #{{:width => @js_cropper_c_i.original_geometry.width, :height => @js_cropper_c_i.original_geometry.height}.to_json},
                targetGeometry: #{{:width => @js_cropper_c_i.target_geometry.width, :height => @js_cropper_c_i.target_geometry.height}.to_json},
                coordNames: #{@js_cropper_c_i.coord_names.to_json}
              })
          );
        </script>
      JS
      
      respond_to?(:raw) ? raw(s) : s
    end
    
    def croppable_image_preview(object_and_name, attachment, style, options = {})
      object, name = split_object_and_name(object_and_name)
      options[:preview_size] = {:width => options.delete(:width), :height => options.delete(:height)} if options[:width] and options[:height]
      return unless options = parse_options(object, options)
      
      s = <<-HTML
      <div style="overflow:hidden;height:#{options[:preview_size][:height]}px;width:#{options[:preview_size][:width]}px;" class="#{options[:css_prefix]}-preview-mask">
        #{image_tag(@js_cropper_c_i.attachment.url(:original), :class => "#{options[:css_prefix]}-preview")}
      </div>
      HTML
      respond_to?(:raw) ? raw(s) : s
    end
    
    private
    def camelize_keys(hash)
      hash.inject({}) do |h, pair|
        h.merge(pair[0].to_s.camelize(:lower) => pair[1])
      end
    end
        
    def split_object_and_name(object_and_name)
      if object_and_name.is_a? Array
        object_and_name
      elsif object_and_name.is_a? ActiveRecord::Base
        [object_and_name, object_and_name.class.model_name]
      else
        [eval("@#{object_and_name.to_s}"), object_and_name]
      end
    end
    
    def parse_options(object, options = {})
      @js_cropper_c_i ||= object.cropped_image
      
      return false unless @js_cropper_c_i.target_geometry and @js_cropper_c_i.original_geometry
      
      @js_cropper_options ||= {}
      @js_cropper_options = {
        :css_prefix => 'jcrop',
        :view_size => {:width => @js_cropper_c_i.target_geometry.width, :height => @js_cropper_c_i.target_geometry.height},
        :preview_size => {:width => @js_cropper_c_i.target_geometry.width, :height => @js_cropper_c_i.target_geometry.height},
        :aspect_ratio => @js_cropper_c_i.target_geometry.width / @js_cropper_c_i.target_geometry.height,
        :original_geometry => {:width => @js_cropper_c_i.original_geometry.width, :height => @js_cropper_c_i.original_geometry.height},
        :starting_crop => @js_cropper_c_i.starting_crop,
        :js_object => 'croppedImage' + ActiveSupport::SecureRandom.hex(10),
        :jcrop_options => @js_cropper_c_i.options[:maintain_aspect_ratio] ? {:aspectRatio => @js_cropper_c_i.target_geometry.width / @js_cropper_c_i.target_geometry.height} : {}
      }.merge(@js_cropper_options.merge(options))
    end
  end
end

class ActionView::Base
  include JCropper::Helpers
end