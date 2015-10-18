$ = require "jquery"

class Animations
  @getAll: ->
    [{ key: "cube", name: "Cube"}, { key: "skybox", name: "Skybox" }]
  constructor: ->
    @animateFn = null

    @scene = new THREE.Scene();
    @camera = new THREE.PerspectiveCamera( 45, window.innerWidth/window.innerHeight, 0.1, 10000 )

    @renderer = new THREE.WebGLRenderer({ alpha: true })
    @renderer.setClearColor( 0x333333, 1);
    @renderer.setSize(window.innerWidth, window.innerHeight)
    $("#visuals").html(@renderer.domElement)

  cubeAnim: =>
    @clearScene()
    geometry = new THREE.BoxGeometry( 1, 1, 1 )
    material = new THREE.MeshBasicMaterial( { color: 0x00ff00 } )
    @cube = new THREE.Mesh( geometry, material )
    @cube.name = "cube"
    @scene.add(@cube)
    @camera.position.z = 5;

    @animateFn = =>
      @cube.rotation.x += 0.1;
      @cube.rotation.y += 0.1;

    callback = =>
      @scene.remove(@cube)

    @render()
    @callbackTimeout = setTimeout callback, 500

  skyboxAnim: =>
    @clearScene()
    @camera.position.z = 30
    cameraChange = 0.05

    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    @skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0x000000, side: THREE.BackSide })
    @skybox = new THREE.Mesh(skyboxGeometry, @skyboxMaterial)
    @scene.add(@skybox)

    @animateFn = =>
      @skyboxMaterial.color.setHex(Math.random() * 0xffffff)

    callback = =>
      @scene.remove(@skybox)

    @render()
    @callbackTimeout = setTimeout callback, 500

  render: =>
    requestAnimationFrame(@render)
    @animateFn()
    @renderer.render(@scene, @camera)

  clearScene: =>
    _.each @scene.children, (object) =>
      @scene.remove(object)
    clearTimeout(@callbackTimeout) if @callbackTimeout
    @callbackTimeout = null


module.exports = Animations
