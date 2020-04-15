var model
var copyprogram
var widgets = {}
var widgetOrder = ['adjustments', 'meanblur5']
var framebuffers = {}
var sourceImage
var lastrender
var renderRequest = false
var renderrate = (1/30)*1000

function prepare (gl) {
  model = prepareModelBuffer(gl)
  sourceImage = loadTexture(gl, 'image.jpg')
  copyprogram = loadShaderPack(gl, __dirname + '/shaders/copy', {
    atrribVertexCoord: 'aVertex',
    atrribTextureCoord: 'aTextureCoord',
    uniforms: {
      'transform': 'transform',
      'texture': 'texSampler',
    }
  })
  widgets.adjustments = loadWidget(gl, __dirname + '/widgets/adjustments.js')
  widgets.gamma = loadWidget(gl, __dirname + '/widgets/gamma.js')
  widgets.meanblur5 = loadWidget(gl, __dirname + '/widgets/meanblur5.js')
  widgets.meanblur9 = loadWidget(gl, __dirname + '/widgets/meanblur9.js')
  widgets.meanblur9x2 = loadWidget(gl, __dirname + '/widgets/meanblur9x2.js')
  widgets.gaussian4 = loadWidget(gl, __dirname + '/widgets/gaussian4.js')
  framebuffers = recreateFrameBuffers(gl, framebuffers, widgets, widgetOrder, 640, 480)
  createWidgetUIs()
}

function triggerRecreateFrameBuffers (gl) {
  framebuffers = recreateFrameBuffers(gl, framebuffers, widgets, widgetOrder, sourceImageWidth * renderquality, sourceImageHeight * renderquality)
}

function update (gl, framebuffers, widgets, widgetOrder, sourceImage) {
  var lastchain = 0
  widgetOrder.forEach((widgetname, i) => {
    var widget = widgets[widgetname]
    var widgetFramebuffers = {}

    // allocate extra framebuffers to this widget if needed
    widget.framebuffers.forEach((name, i) => { widgetFramebuffers[name] = framebuffers.extra[i] });

    // chose what framebuffers will be the input and output
    lastchain = (1-lastchain)
    var source = framebuffers.chain[lastchain].texture
    var destfb = framebuffers.chain[1-lastchain]
    if (i === 0) {
      // if this is the first widget, pull from the source image
      source = sourceImage
    }
    if (i === widgetOrder.length-1) {
      // if this is the last widget, use the result framebuffer
      destfb = framebuffers.final
    }
    runWidget(gl, widget, source, destfb, widgetFramebuffers)
  });
}

function updateFromFramebuffers (gl, framebuffer, dst, tin) {
  // bind the program and framebuffer
  gluse(gl, copyprogram, model)
  useFB(gl, dst)
  // bind the final texture
  gl.activeTexture(gl.TEXTURE0)
  gl.bindTexture(gl.TEXTURE_2D, framebuffer)
  gl.uniform1i(copyprogram.uniformLocations.texture, 0)
  // create the transform matrix
  const transform = mat4.create()
  mat4.scale(transform, transform, tin.scale)
  mat4.translate(transform, transform, tin.translate)
  gl.uniformMatrix4fv(copyprogram.uniformLocations.transform, false, transform)
  draw (gl)
}

function updateCanvas (gl, x,y, scale, framebuffer) {
  requestAnimationFrame(function(){
    updateFromFramebuffers(gl, framebuffer, null, {
      translate: [x, y, 0],
      scale: [scale, -(pcaspect)/(framebuffers.final.width/framebuffers.final.height)*scale, 1],
    })
  })
}

function render (gl) {
  update(gl, framebuffers, widgets, widgetOrder, sourceImage)
  gl.finish()
  updateCanvasMouse(pgl)
  gl.finish()
}

function updateCycle () {
  var start = new Date()
  if (renderRequest) {
    render(pgl)
    renderRequest = false
  }
  setTimeout(function(){ requestAnimationFrame(updateCycle) }, renderrate-(new Date() - start))
}

function sheduleRender() {
  renderRequest = true
}