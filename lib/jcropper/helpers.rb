module JCropper 
  module Helpers
    def croppable_image(object_name, attachment, style, options = {})
      object = eval("@#{object_name.to_s}") unless object_name.is_a? ActiveRecord::Base
      options[:view_size] = {:width => options.delete(:width), :height => options.delete(:height)}
      return unless options = parse_options(object, options)

      ###CRZ - duplicated in JS!
      view_scale = find_bounding_scale([options[:view_size][:width], options[:view_size][:height]],
                    [options[:original_geometry][:width], options[:original_geometry][:height]])

      scaled_img_dims = {:width => options[:original_geometry][:width]*view_scale, :height => options[:original_geometry][:height]*view_scale}
      s = "<div class='#{options[:css_prefix]}'>#{image_tag(object.send(attachment).url, scaled_img_dims.merge(:id => options[:id]))}</div>" + "\n"
      s += hidden_field_tag("#{object_name}[#{@js_cropper_c_i.coord_names[:x]}]", @js_cropper_c_i.starting_crop[:x], :id => @js_cropper_c_i.coord_names[:x]) + "\n"
      s += hidden_field_tag("#{object_name}[#{@js_cropper_c_i.coord_names[:y]}]", @js_cropper_c_i.starting_crop[:y], :id => @js_cropper_c_i.coord_names[:y]) + "\n"
      s += hidden_field_tag("#{object_name}[#{@js_cropper_c_i.coord_names[:w]}]", @js_cropper_c_i.starting_crop[:w], :id => @js_cropper_c_i.coord_names[:w]) + "\n"
      s += hidden_field_tag("#{object_name}[#{@js_cropper_c_i.coord_names[:h]}]", @js_cropper_c_i.starting_crop[:h], :id => @js_cropper_c_i.coord_names[:h]) + "\n"
      s += <<-JS
        <script type="text/javascript">
          #{options[:js_object]} = new CroppedImage(jQuery('.#{options[:css_prefix]} img'),
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
      s
    end
    
    def croppable_image_preview(object_name, attachment, style, options = {})
      object = eval("@#{object_name.to_s}") unless object_name.is_a? ActiveRecord::Base      
      options[:preview_size] = {:width => options.delete(:width), :height => options.delete(:height)}
      return unless options = parse_options(object, options)
      
      s = <<-HTML
      <div style="overflow:hidden;height:#{options[:preview_size][:height]}px;width:#{options[:preview_size][:width]}px;" class="#{options[:css_prefix]}-preview-mask">
        #{image_tag(@js_cropper_c_i.attachment.url(:original), :class => "#{options[:css_prefix]}-preview")}
      </div>
      HTML
      s
    end
    
    private
    def camelize_keys(hash)
      hash.inject({}) do |h, pair|
        h.merge(pair[0].to_s.camelize(:lower) => pair[1])
      end
    end
    
    def find_bounding_scale(container, to_contain)
      to_contain_aspect = to_contain[0].to_f / to_contain[1]
      container_aspect = container[0].to_f / container[1]

      if to_contain_aspect > container_aspect
        return (container[0].to_f / to_contain[0]);
      else
        return (container[1].to_f / to_contain[1]);
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
        :js_object => 'croppedImage'
      }.merge(@js_cropper_options.merge(options))
    end
  end
end

class ActionView::Base
  include JCropper::Helpers
end