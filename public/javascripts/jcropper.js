CroppedImage = function(image, properties) {
  var t = this;
  t.image = image;
  
  t.init = function(properties) {
    $(window).load(function() {
      t.jcrop = jQuery.Jcrop(t.image, jQuery.extend(t.defaultJcropOptions(), t.jcropOptions));
    });
  }

  t.defaultJcropOptions = function() {
    return {
      onChange: t.cropOnChange,
      onSelect: t.cropOnChange,
      trueSize: [t.originalGeometry.width, t.originalGeometry.height],
      setSelect: [  
        t.startingCrop.x * t.viewScale(),
        t.startingCrop.y * t.viewScale(),
        (t.startingCrop.x + t.startingCrop.w) * t.viewScale(),
        (t.startingCrop.y + t.startingCrop.h) * t.viewScale()
      ]
    }
  },

  t.viewScale = function() {
    return t.findBoundingScale([t.viewSize.width, t.viewSize.height], 
                               [t.originalGeometry.width, t.originalGeometry.height]);
  } 
  
  t.log = function() {
    try {
      if(typeof console == 'object' && typeof console.log == 'function') {
        console.log.apply(console, arguments);
      }
    } catch(e) {;}
  }
  
  t.cropOnChange = function(coords) {
    t.updatePreview(coords);

    $('#' + t.coordNames.x).val(coords.x);
    $('#' + t.coordNames.y).val(coords.y);
    $('#' + t.coordNames.w).val(coords.w);
    $('#' + t.coordNames.h).val(coords.h);
  }

  t.findBoundingScale = function(container, toContain) { /* [width, height] arrays */
    toContainAspect = toContain[0] / toContain[1]
    containerAspect = container[0] / container[1]

    if(toContainAspect > containerAspect) {
      return (container[0] / toContain[0]);
    }
    else {
      return (container[1] / toContain[1]);
    }
  }
  
  t.addProperties = function(properties) {
    jQuery.extend(t, properties);
  }

  t.previewMask = function() {
    return jQuery('.' + t.cssPrefix + '-preview').parent();
  }

  t.updatePreview = function(coords) {
    if(coords.x == NaN || t.previewMask().length == null ) { 
      return;
    }

    var rx = t.previewMask().width() / coords.w;
    var ry = t.previewMask().height() / coords.h;
    var scale = t.findBoundingScale([t.previewSize.width, t.previewSize.height], 
                                    [coords.w, coords.h])

    t.previewMask().css({
      width: Math.round(scale * coords.w) + 'px',
      height: Math.round(scale * coords.h) + 'px',
    });
  
    $('.' + t.cssPrefix + '-preview').css({
            width: Math.round(scale * t.originalGeometry.width) + 'px',
            height: Math.round(scale * t.originalGeometry.height) + 'px',
            marginLeft: '-' + Math.round(scale * coords.x) + 'px',
            marginTop: '-' + Math.round(scale * coords.y) + 'px'
    });
  }

  t.resetCrop = function() {
    t.jcrop.setSelect([t.startingCrop.x, 
                       t.startingCrop.y, 
                       t.startingCrop.x + t.startingCrop.w, 
                       t.startingCrop.y + t.startingCrop.h]);
  }
  
  t.clearCrop = function() {
    t.jcrop.setSelect([0, 0, t.originalGeometry.width, t.originalGeometry.height]);
  }
    
  t.init(properties);
  t.addProperties(properties);   //###CRZ - there are no defaults here
};

