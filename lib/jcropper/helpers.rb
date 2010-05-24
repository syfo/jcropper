module JCropper
  module Helpers
    def croppable_image(object_name, attachment, style, options = {})
      object = eval("@#{object_name.to_s}") unless object_name.is_a? ActiveRecord::Base
      return unless options = default_options(object, attachment, style, options)

      s = "<div class='#{options[:css_prefix]}'>#{image_tag(object.send(attachment).url, options[:view_size].merge(:id => options[:id]))}</div>" + "\n"
      s += hidden_field_tag("#{object_name}[#{@c_i.coord_names[:x]}]", @c_i.starting_crop[:x], :id => @c_i.coord_names[:x]) + "\n"
      s += hidden_field_tag("#{object_name}[#{@c_i.coord_names[:y]}]", @c_i.starting_crop[:y], :id => @c_i.coord_names[:y]) + "\n"
      s += hidden_field_tag("#{object_name}[#{@c_i.coord_names[:w]}]", @c_i.starting_crop[:w], :id => @c_i.coord_names[:w]) + "\n"
      s += hidden_field_tag("#{object_name}[#{@c_i.coord_names[:h]}]", @c_i.starting_crop[:h], :id => @c_i.coord_names[:h]) + "\n"
      (s += common_js(options)) and (@common_js_included = true) unless @common_js_included
      s += <<-JS         
        <script type="text/javascript">
          var cropImageScale = findBoundingScale([#{options[:view_size][:width]}, #{options[:view_size][:height]}], 
                                                 [#{@c_i.original_geometry.width}, #{@c_i.original_geometry.height}])
                    
          $('.#{options[:css_prefix]} img').attr('width', parseInt(cropImageScale*#{@c_i.original_geometry.width}));
          $('.#{options[:css_prefix]} img').attr('height', parseInt(cropImageScale*#{@c_i.original_geometry.height}));
        
          $(window).load(function() {
            #{options[:jcrop_object]} = $.Jcrop('.#{options[:css_prefix]} img', {
              onChange: cropOnChange,
              onSelect: cropOnChange,
              #{options[:jcrop_options].map{|k,v| "#{k.to_s}: #{v.to_json},\n"}}
            });
          });
        </script>
      JS
    end
    
    def croppable_image_preview(object_name, attachment, style, options = {})
      object = eval("@#{object_name.to_s}") unless object_name.is_a? ActiveRecord::Base      
      options[:preview_size] = options.delete(:view_size)
      return unless options = default_options(object, attachment, style, options)
      
      s = <<-HTML
      <div style="overflow:hidden;height:#{options[:preview_size][:height]}px;width:#{options[:preview_size][:width]}px;" class="#{options[:css_prefix]}-preview-mask">
        #{image_tag(object.send(attachment).url(:original), :class => "#{options[:css_prefix]}-preview")}
      </div>
      HTML
      (s += common_js(options)) and (@common_js_included = true) unless @common_js_included
      s
    end
    
    private
    def common_js(options)
      <<-HTML
        <script type="text/javascript">
          function cropOnChange(coords) {
            if(typeof updatePreview == 'function') {
              updatePreview(coords);
            }

            $('##{@c_i.coord_names[:x]}').val(coords.x);
            $('##{@c_i.coord_names[:y]}').val(coords.y);
            $('##{@c_i.coord_names[:w]}').val(coords.w);
            $('##{@c_i.coord_names[:h]}').val(coords.h);
          }

          function updatePreview(coords) {
            if(coords.x == NaN) { return; }

            var previewMask = $('.#{options[:css_prefix]}-preview').parent();
            var rx = previewMask.width() / coords.w;
            var ry = previewMask.height() / coords.h;
            var scale = findBoundingScale([#{options[:view_size][:width]}, #{options[:view_size][:height]}], [coords.w, coords.h])

            previewMask.css({
              width: Math.round(scale * coords.w) + 'px',
              height: Math.round(scale * coords.h) + 'px',
            });
          
            $('.#{options[:css_prefix]}-preview').css({
                    width: Math.round(scale * #{@c_i.original_geometry.width}) + 'px',
                    height: Math.round(scale * #{@c_i.original_geometry.height}) + 'px',
                    marginLeft: '-' + Math.round(scale * coords.x) + 'px',
                    marginTop: '-' + Math.round(scale * coords.y) + 'px'
            });
          }

          function findBoundingScale(container, toContain) { /* [width, height] arrays */
            toContainAspect = toContain[0] / toContain[1]
            containerAspect = container[0] / container[1]
    
            if(toContainAspect > containerAspect) {
              return (container[0] / toContain[0]);
            }
            else {
              return (container[1] / toContain[1]);
            }
          }
        </script>
      HTML
    end
    
    def find_bounding_scale(container, to_contain)
      to_contain_aspect = to_contain[0] / to_contain[1]
      container_aspect = container[0] / container[1]

      if to_contain_aspect > container_aspect
        return (container[0] / to_contain[0]);
      else
        return (container[1] / to_contain[1]);
      end
    end
    
    def default_options(object, attachment, style, options = {})
      @c_i ||= object.cropped_image
      
      options = {
        :css_prefix => 'jcrop',
        :jcrop_object => 'jcrop_api',
        :view_size => {:width => @c_i.original_geometry.width, :height => @c_i.original_geometry.height},
        :preview_size => {:width => @c_i.original_geometry.width, :height => @c_i.original_geometry.height},
        :aspect_ratio => @c_i.target_geometry.width / @c_i.target_geometry.height,
      }.merge(options)

      scale = find_bounding_scale([options[:view_size][:width], options[:view_size][:height]], 
                                  [@c_i.original_geometry.width, @c_i.original_geometry.height])

      options[:jcrop_options] = {
        :setSelect => [ @c_i.starting_crop[:x] * scale, 
                        @c_i.starting_crop[:y] * scale, 
                        @c_i.starting_crop[:x] + @c_i.starting_crop[:w] * scale,
                        @c_i.starting_crop[:y] + @c_i.starting_crop[:h] * scale
                       ],
        :trueSize  => [@c_i.original_geometry.width, @c_i.original_geometry.height]
      }
      
      options
    end
  end
end

class ActionView::Base
  include JCropper::Helpers
end