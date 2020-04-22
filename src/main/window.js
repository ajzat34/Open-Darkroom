const { ipcRenderer, remote } = require('electron')
const dialog = remote.dialog
const fs = require('fs')

// preview pane
var preview     // preview pane element (the big one on the left)
var pc          // preview canvas
var pgl         // preview canvas webgl2 context
var pcaspect    // preview canvas aspect ratio

// options bar
var options             // options pane element
var optionsSize = 320   // width of the options pane

// height of the top toolbar
var toolbarSize = 48

// width and height of the image
// this gets changed when the image is loaded
var sourceImageWidth = 2
var sourceImageHeight = 2

// viewport data
var scroll = [0,0]             // current window scroll
var mosusepos = [0,0]
var scale = 0.99               // current zoom amount
var viewscale = scale*scale    // the render scale = zoom^2
var mouse                      // is the mouse up or down

var updateRequest = false      // set to when signalling that the image needs to be re-rendered
var renderRequest = false      // same for canvas updates

var widgetUiElements           // array of widgets (collections of dom elements)

var renderTimeStat = 0         // stores how long the last render took

var envdata   // data about the environment

// override macos natural scrolling reversal
// this will be a preference later
var normalscroll = false

// holds to global state of all adjustments (widget knobs)
var widgetState = {}

// autosave and undo history
var undoHistory = new UndoHistory(32) // holds the undo history
var historyTimer                      // timer to batch change events
var autosaveTimer                     // same as above, but for autosave

// webgl objects
var model             // holds the webgl object for the model
var copyprogram       // webgl shader program for
var widgets = {}      // holds the widget descriptors
var widgetOrder = ['adjustments', 'details'] // order to apply widgets
var framebuffers = {} // holds all of the framebuffers (chain, final, extra)
var sourceImage       // texture with the source image

// image loading
var imageB64          // base64 encoded copy of the original image
var imageFormat       // what format (png, jpeg) was the original image in
var imagePath         // where was the loaded image located
var srcPackage        // holds a copy of the loaded dkg/dkr if one was loaded

function resize () {
  var width = window.innerWidth - optionsSize
  var height = window.innerHeight - toolbarSize
  options.style.width = `${optionsSize}px`
  preview.style.width = `${width}px`
  pc.width = (width) * window.devicePixelRatio
  pc.height = (height) * window.devicePixelRatio
  pc.style.width = `${width}px`
  pc.style.height = `${height}px`
  pcaspect = pc.width/pc.height
  glResize(pgl)
  scheduleUpdate()
}

// callback when the image loads
async function eventImageLoad (image) {
  sourceImageWidth = image.width
  sourceImageHeight = image.height
  triggerRecreateFrameBuffers(pgl)
  // shedule the first render
  scheduleRender()
  // wait for first render to finish
  await asyncGlFence(pgl, pgl.fenceSync(pgl.SYNC_GPU_COMMANDS_COMPLETE, 0), 10)
  // wait for the paint then tell the main process to show this window
  window.requestAnimationFrame(function(){
    setTimeout(function(){
      ipcRenderer.send('mainwindow-loaded')
    }, 200)
  })
  // load the saved state
  if (srcPackage) {
    loadPackage(srcPackage, imagePath)
  }

  // create the initial history snapshot
  createHistorySnapshot()

  // start the render loop
  updateCycle()
  updateCanvasCycle()
}

// callback for canvas event mousemove
// updates the canvas position and schedules an update when the mouse moves
function mouseMoveHandler (e) {
  if (mouse === 'down'){
    deltaX = (e.clientX - mosusepos[0]) / viewscale
    deltaY = (e.clientY - mosusepos[1]) / viewscale
    scroll = [scroll[0]+deltaX, scroll[1]+deltaY]
    mosusepos = [e.clientX, e.clientY]
    scheduleUpdate()
  }
}

function mouseDownHandler (e) {
  mosusepos = [e.clientX, e.clientY]
  mouse = 'down'
}

function mouseUpHandler () {
  mouse = 'up'
}

function mouseWheelHandler (e) {
  // correct for macOS "natural scrolling"
  if (!envdata.darwin || normalscroll) {
    scale += e.wheelDelta/5000
  } else {
    scale -= e.wheelDelta/5000
  }
  scale = Math.max(Math.min(scale, 50), 0.1)
  viewscale = scale*scale
  scheduleUpdate()
}

function setupButtonEvents() {
  // macOS button events
  document.getElementById("min-btn").addEventListener("click", function (e) {
       var window = remote.getCurrentWindow();
       window.minimize()
  })
  document.getElementById("max-btn").addEventListener("click", function (e) {
       var window = remote.getCurrentWindow();
       if (!window.isMaximized()) {
           window.maximize()
       } else {
           window.unmaximize()
       }
  })
  document.getElementById("close-btn").addEventListener("click", function (e) {
       var window = remote.getCurrentWindow();
       window.close();
  })

  // compare button events
  document.getElementById('btn-compare').addEventListener("mousedown", function(e) {
    updateCanvasMouseCompare()
  })
  document.getElementById('btn-compare').addEventListener("mouseup", function(e) {
    updateCanvasMouse()
  })
}

function gatherWindowData () {
  envdata = remote.getGlobal('envdata')
}

document.addEventListener("DOMContentLoaded", function(){

  // get window panes
  preview = document.getElementById('preview-pane')
  options = document.getElementById('options-pane')

  // get buttons
  savebutton = document.getElementById('btn-save')

  // webgl / preview canvas
  pc = document.getElementById('preview_canvas')
  pc.addEventListener('mousedown', mouseDownHandler)
  window.addEventListener('mouseup', mouseUpHandler)
  window.addEventListener('mousemove', mouseMoveHandler)
  pc.addEventListener("mousewheel", mouseWheelHandler, false);
  pgl = getWebGL(pc)
  if (!pgl) {
    alert('WebGL is not supported')
    remote.getCurrentWindow().close()
    return
  }

  gatherWindowData()

  // start loading assets
  prepare(pgl)
  // initial sizing
  resize()
  // and an eventlistener for resizing
  window.addEventListener('resize', resize)

  // listen for ipc for menu items
  ipcRenderer.on('undo', undo)
  ipcRenderer.on('redo', redo)
  ipcRenderer.on('save', saveProject)
  ipcRenderer.on('save-as', saveProjectAs)

  setupButtonEvents()
})


// ------ rendering ------

// this is the main render loop
// the scheduleRender() function is used to
// notify this loop that a render needs to occur.
async function updateCycle () {
  var start = new Date()
  var rendered = false
  if (renderRequest) {
    rendered = true
    renderRequest = false
    render(pgl)
  }

  // this should help ensure that the render occurs before drawing it to the canvas
  // it is NOT a sync, it just tells the drivers to "encourage eager execution of enqueued commands"
  pgl.flush()

  // wait for the gpu finish
  await asyncGlFence(pgl, pgl.fenceSync(pgl.SYNC_GPU_COMMANDS_COMPLETE, 0), 10)

  if (rendered) {
    scheduleUpdate()
  }

  // record some stats
  renderTimeStat = (new Date()-start)
  if (rendered) {
    console.log('render took', renderTimeStat, 'ms')
  }

  // do it all over again at least 1ms later
  setTimeout(function(){
    requestAnimationFrame(updateCycle)
  }, 1)
}

// this is the canvas update loop
// scheduleUpdate() function is used to
// notify this loop that an update needs to occur.
async function updateCanvasCycle () {
    if (updateRequest) {
      updateRequest = false
      updateCanvasMouse()
    }
    // do it all over again at least 1ms later
    setTimeout(function(){
      requestAnimationFrame(updateCanvasCycle)
    }, 1)
}

// tell the above render loop to update the final image or canvas
function scheduleRender() { renderRequest = true }
function scheduleUpdate() { updateRequest = true }

// TODO: add history
function projectChange(fromUndo) {
  scheduleRender()
  historyEventProjectChanged(fromUndo)
}

// helper functinos for calculating scrolling
function updateCanvasMouse () {
  var width = window.innerWidth - optionsSize
  var height = window.innerHeight
  updateCanvas(pgl, (scroll[0])/(width/2), (scroll[1])/(height/2), viewscale, framebuffers.final.texture)
}

function updateCanvasMouseCompare () {
  var width = window.innerWidth - optionsSize
  var height = window.innerHeight
  updateCanvas(pgl, (scroll[0])/(width/2), (scroll[1])/(height/2), viewscale, sourceImage)
}
