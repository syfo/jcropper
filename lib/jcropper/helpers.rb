module JCropper
  module Helpers
    def croppable_image(object_name, attachment, style, options = {})
      object = eval("@#{object_name.to_s}") unless object_name.is_a? ActiveRecord::Base
      paperclip_options = object.send(attachment).styles[style.to_sym]
      options = options.merge(default_options)

      x, y, w, h = ['x', 'y', 'w', 'h'].map{|v| "#{attachment}_crop_#{v}"}
      
      target_geometry = Paperclip::Geometry.parse(paperclip_options[:geometry])
      file_geometry = Paperclip::Geometry.from_file(object.send(attachment).path(:original))
      options[:view_size] ||= {:width => file_geometry.width, :height => file_geometry.height}

      resized_ratio = options[:view_size][:width] / file_geometry.width 

      s = "<div class='#{options[:css_prefix]}'>#{image_tag(object.send(attachment).url, options[:view_size])}</div>" + "\n"
      s += hidden_field_tag("#{object_name}[#{x}]", object.send(x), :id => x) + "\n"
      s += hidden_field_tag("#{object_name}[#{y}]", object.send(y), :id => y) + "\n"
      s += hidden_field_tag("#{object_name}[#{w}]", object.send(w), :id => w) + "\n"
      s += hidden_field_tag("#{object_name}[#{h}]", object.send(h), :id => h) + "\n"
      s += <<-CSS
        <style type="text/css">
          /* Fixes issue here http://code.google.com/p/jcrop/issues/detail?id=1 */
          .jcrop-holder { text-align: left; }

          .jcrop-vline, .jcrop-hline
          {
          	font-size: 0;
          	position: absolute;
          	background: white url('Jcrop.gif') top left repeat;
          }
          .jcrop-vline { height: 100%; width: 1px !important; }
          .jcrop-hline { width: 100%; height: 1px !important; }
          .jcrop-handle {
          	font-size: 1px;
          	width: 7px !important;
          	height: 7px !important;
          	border: 1px #eee solid;
          	background-color: #333;
          	*width: 9px;
          	*height: 9px;
          }

          .jcrop-tracker { width: 100%; height: 100%; }

          .custom .jcrop-vline,
          .custom .jcrop-hline
          {
          	background: yellow;
          }
          .custom .jcrop-handle
          {
          	border-color: black;
          	background-color: #C7BB00;
          	-moz-border-radius: 3px;
          	-webkit-border-radius: 3px;
          }
        </style>
      CSS
      
      s += <<-HTML
        <script type='text/javascript'>
          function findBoundingScale(img, container) {
            imgAspect = img[0] / img[1]
            containerAspect = container[0] / container[1]
      
            if(imgAspect < containerAspect) {
              return (container[0] / img[0]);
            }
            else
              return (container[1] / img[1]);
            }
          }
        
          $('.#{options[:css_prefix]} img').load(function() {
            var trueWidth = #{file_geometry.width};
            var trueHeight = #{file_geometry.height};
        
            var targetWidth = #{target_geometry.width};
            var targetHeight = #{target_geometry.height};
                
            function cropOnChange(coords) {
              var rx = $('##{options[:css_prefix]}-preview').parent().width() / coords.w;
              var ry = $('##{options[:css_prefix]}-preview').parent().height() / coords.h;

              $('##{options[:css_prefix]}-preview').css({
                      width: Math.round(rx * trueWidth) + 'px',
                      height: Math.round(ry * trueHeight) + 'px',
                      marginLeft: '-' + Math.round(rx * coords.x) + 'px',
                      marginTop: '-' + Math.round(ry * coords.y) + 'px'
              });
        
              $('##{x}').val(coords.x);
              $('##{y}').val(coords.y);
              $('##{w}').val(coords.w);
              $('##{h}').val(coords.h);
              console.log(coords);
            }

            api = $('.#{options[:css_prefix]} img').Jcrop({
              #{options[:jcrop_options].map{|k,v| "#{k.to_s}: #{v.to_s},\n"}}
              setSelect: #{[object.send(x), object.send(y), 
                              object.send(x) + object.send(w), object.send(y) + object.send(h)].map {|v| v*resized_ratio}.to_json},
              onChange: cropOnChange,
              onSelect: cropOnChange,
  //            aspectRatio: targetWidth / targetHeight,
              trueSize: [trueWidth, trueHeight]
            });
          });
        </script>
      HTML
    end
    
    def croppable_image_preview(object_name, attachment, style, options = {})
      object = eval("@#{object_name.to_s}") unless object_name.is_a? ActiveRecord::Base      
      options = options.merge(default_options)
      
      <<-HTML
      <div style="overflow:hidden;border:1px solid black;">
        #{image_tag(object.send(attachment).url(:original), :id => "#{options[:css_prefix]}-preview")}
      </div>
      HTML
    end
    
    private
    def default_options
      {
        :css_prefix => 'js_crop',
        :jcrop_options => {}
      }
    end
  end
end

class ActionView::Base
  include JCropper::Helpers
end