$ = require "jquery"
_ = require "underscore"

class Animations
  @getAll: ->
    [
      { key: "blank", name: "Blank" },
      { key: "random", name: "Randomize"},
      { key: "logo", name: "Synthery"},
      { key: "madeWithJS", name: "Made with JS"},
      { key: "spinningDiamond", name: "Spinning Diamond" },
      { key: "flash", name: "Flashing Colors" },
      { key: "flashToBlack", name: "Flashing Colors To Black" },
      { key: "singleRandomBgColor", name: "Single Random Background Color" },
      { key: "backgroundColorShift", name: "Shift Random Background Color" },
      { key: "randomBgColors", name: "Random Background Colors" },
      { key: "spinningCircleZoom", name: "Spinning Circle Zoom"},
      { key: "rotatingCube", name: "Rotating Cube" },
      { key: "enhancedRotatingCube", name: "Enhanced Rotating Cube" },
      { key: "cubeAttack", name: "Cube Attack" },
      { key: "rotatingSphereMesh", name: "Rotating Sphere Mesh" },
      { key: "enhancedRotatingSphereMesh", name: "Enhanced Rotating Sphere Mesh" },
      { key: "movingTriangles", name: "Moving Triangles" },
      { key: "enhancedMovingTriangles", name: "Enhanced Moving Triangles" },
      { key: "minimalSphereMesh", name: "Minimal Sphere Mesh" },
      { key: "explodingSphere", name: "Exploding Sphere" },
      { key: "confetti", name: "Confetti"},
      { key: "splittingSphereTop", name: "Splitting Sphere - Top" },
      { key: "splittingSphereBottom", name: "Splitting Sphere - Bottom" },
      { key: "sideSplittingSphereDown", name: "Side Splitting Sphere - Down" },
      { key: "sideSplittingSphereUp", name: "Side Splitting Sphere - Up" },
      { key: "dancingSphere", name: "Dancing Sphere" },
      { key: "trippyDancingSphere", name: "Trippy Dancing Sphere" },
      { key: "trippyDancingSphereWithColors", name: "Trippy Dancing Sphere with colors" },
      { key: "discoball", name: "Discoball" },
      { key: "enhancedDiscoball", name: "Enhanced Discoball" },
      { key: "enhancedDiscoballOnStars", name: "Enhanced Discoball on Stars"},
      { key: "starrySkies", name: "Starry Skies" },
      { key: "radioactive", name: "Radioactive"},
      { key: "linesphere", name: "Orange Sphere"},
      { key: "uberTriangle", name: "Uber Triangle", preloadGif: true },
      { key: "rotatingAxes", name: "Rotating Axes", preloadGif: true}
    ]
  @getDefault: ->
    @getAll()[0]

  constructor: (target)->
    @bpm = 468.75
    @animateFn = null
    @animateNeverFn = null
    @neverReq = 0
    @request = 0
    @stopping = false
    @target = target

    @scene = new THREE.Scene()
    @camera = new THREE.PerspectiveCamera(45, $(target).width()/$(target).height(), 0.1, 10000 )

    @renderer = new THREE.WebGLRenderer()
    @renderer.setClearColor(0x333333)
    @renderer.setPixelRatio(window.devicePixelRatio)
    @renderer.setSize($(@target).width(), $(@target).height())

    $(@target).append(@renderer.domElement)
    window.addEventListener('resize', @onWindowResize)
    @renderer.clear()

    @preloadGifs()

  preloadGifs: (imagesToPreload) ->
    images = new Array()
    preload = () ->
      for imgSrc in imagesToPreload
        img = new Image()
        img.src = "/gifs/#{imgSrc}.gif"
        images.push(img)

    imagesToPreload =
      (anim for anim in @constructor.getAll() when anim.preloadGif?).map((anim) -> anim.key)
    preload(imagesToPreload)

  onWindowResize: =>
    @camera.aspect = $(@target).width() / $(@target).height()
    @camera.updateProjectionMatrix()
    @renderer.setSize $(@target).width(), $(@target).height()

  updateBPM: (inputbpm) =>
      @bpm = 60000/inputbpm

  createGifAnim: (filename) =>
    @clearScene()
    $("#visuals").hide()
    $("#fullscreen-visuals").hide()

    $("#gif-animator").html("<img src='/gifs/#{filename}' />")
    $("#fullscreen-gif-animator").html("<img src='/gifs/#{filename}' />")

    $("#gif-wrapper").show()
    $("#fullscreen-gif-animator").show()

    @animateFn = ()  =>
    callback = =>
      @showCanvas()

  blankAnim: =>

  randomAnim: =>
    clearInterval(@randomInt) if @randomInt?
    anim = _.sample(Animations.getAll()).key
    @[anim+"Anim"]()
    @randomInt = setInterval((() =>
      anim = _.sample(Animations.getAll()).key
      @[anim+"Anim"]()
    ), 10000)

  uberTriangleAnim: =>
    callback = @createGifAnim("uberTriangle.gif")
    @render()
    # @callbackTimeout = setTimeout callback, 5000

  rotatingAxesAnim: =>
    callback = @createGifAnim("rotatingAxes.gif")
    @render()
    @callbackTimeout = setTimeout callback, 5000

  ### ONE SHOTS ###

  flashAnim: =>
    @camera.position.z = 50

    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0x000000, side: THREE.BackSide })
    skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(skybox)

    animateFn = =>
      skyboxMaterial.color.setHex(Math.random() * 0xffffff)

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(skybox)
      cancelAnimationFrame(req)
      skybox = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 400

  spinningDiamondAnim: =>
    @camera.position.z = 50

    #LINES
    lineMaterial = new THREE.LineBasicMaterial({
      color:0xFFFFFF, linewidth: 50, transparent:true
    });

    lineGeometry1 = new THREE.Geometry()
    lineGeometry1.vertices.push(
      new THREE.Vector3( -20, 0, 0 ),
      new THREE.Vector3( 0, 10, 0 ),
      new THREE.Vector3( 20, 0, 0 )
    );

    lineGeometry2 = new THREE.Geometry()
    lineGeometry2.vertices.push(
      new THREE.Vector3( -20, 0, 0 ),
      new THREE.Vector3( 0, -10, 0 ),
      new THREE.Vector3( 20, 0, 0 )
    );

    line1 = new THREE.Line(lineGeometry1, lineMaterial)
    line1.visible = false
    @scene.add(line1)

    line2 = new THREE.Line(lineGeometry2, lineMaterial)
    line2.visible = false
    @scene.add(line2)

    line1.visible = true
    line2.visible = true
    line1.rotation.y = 5
    line2.rotation.y = -5

    animateFn = =>
      if (line1.rotation.y==0)

        line1.rotation.y += 0
      else
        line1.rotation.y += (0-line1.rotation.y)/20

      if (line2.rotation.y==0)
        line2.rotation.y += 0
      else
        line2.rotation.y += (0-line2.rotation.y)/20

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(line1)
      @scene.remove(line2)
      cancelAnimationFrame(req)
      line1 = null
      line2 = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 1600

  singleRandomBgColorAnim: =>
    @camera.position.z = 50

    bskyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    bskyboxMaterial = new THREE.MeshBasicMaterial({ color: 0xcccccc, side: THREE.BackSide })
    bskyboxMaterial.color.setHex(Math.random() * 0xffffff)
    bskybox = new THREE.Mesh(bskyboxGeometry, bskyboxMaterial)
    @scene.add(bskybox)

    callback = =>
      @scene.remove(bskybox)
      bskybox = null
      @renderer.render(@scene, @camera)

    @renderer.render(@scene, @camera)
    callbackTimeout = setTimeout callback, 1600

  backgroundColorShiftAnim: =>
    @camera.position.z = 50

    #ELEMENTS
    skyboxGeometry2 = new THREE.CubeGeometry(100, 100, 1)
    skyboxMaterial2 = new THREE.MeshBasicMaterial(
      color: 0x000000
      side: THREE.BackSide)
    skybox2 = new THREE.Mesh(skyboxGeometry2, skyboxMaterial2)
    @scene.add(skybox2)
    skybox2.position.x = -100

    randomColor = Math.random() * 0xffffff
    chance = Math.random()
    skyboxMaterial2.color.setHex randomColor

    if chance < .25
      skybox2.position.x = -100
    else if chance < .5
      skybox2.position.x = 100
    else if chance < .75
      skybox2.position.y = -100
    else if chance < 1
      skybox2.position.y = 100

    animateFn= =>
      skybox2.position.x += (0 - skybox2.position.x)/15;
      skybox2.position.y += (0 - skybox2.position.y)/15;

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(skybox2)
      cancelAnimationFrame(req)
      skybox2 = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 1600

  rotatingCubeAnim: =>
    @camera.position.z = 50

    #CUBES
    geometry = new THREE.BoxGeometry(15,15,15)
    material = new THREE.MeshBasicMaterial({color: 0xff0000, opacity:0.5, transparent:true})
    material.color.setHex(Math.random() * 0xffffff)
    cube1 = new THREE.Mesh(geometry,material)
    cube1.rotation.x = (Math.PI/3)
    cube1.rotation.y = (Math.PI/3)
    cube1.rotation.z = (Math.PI/3)
    @scene.add(cube1)

    animateFn = =>
      cube1.rotation.x += .01
      cube1.rotation.y += .02
      cube1.rotation.z += .03

    anim1 = =>
      material.color.setHex(Math.random() * 0xffffff)

    inter = setInterval anim1, (@bpm*4)

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      clearInterval(inter)
      @scene.remove(cube1)
      cancelAnimationFrame(req)
      cube1 = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 2000

  rotatingSphereMeshAnim: =>
    @camera.position.z = 50

    #SPHERES
    sphereMaterial = new THREE.MeshBasicMaterial({color:0xff0000, wireframe: true, wireframeLinewidth:9, transparent: true, opacity: 0.5})
    sphereGeometry = new THREE.SphereGeometry( 15,8,8,0,6.3,3,2.5 )

    sphereMaterial.color.setHex(Math.random() * 0xffffff)
    sphere = new THREE.Mesh( sphereGeometry, sphereMaterial )
    sphere.position.set(0,-15,0)
    @scene.add(sphere)

    sphere2 = new THREE.Mesh(sphereGeometry,sphereMaterial)
    sphere2.position.set(0,15,0)
    sphere2.rotation.z = Math.PI
    @scene.add(sphere2);

    animateFn = =>
      sphere.rotation.y +=.04
      sphere2.rotation.y += .04
      sphere.position.z += (40 - sphere.position.z)/40
      sphere2.position.z += (40 - sphere2.position.z)/40

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(sphere)
      @scene.remove(sphere2)
      cancelAnimationFrame(req)
      sphere = null
      sphere2 = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 2000

  movingTrianglesAnim: =>
    @camera.position.z = 50

    #ELEMENTS
    #TRIANGLES
    lineMaterial = new THREE.LineBasicMaterial({
      color:0xff0000, linewidth: 50, transparent:true
    })

    triangleGeometry = new THREE.Geometry()

    triangleGeometry.vertices.push(
      new THREE.Vector3(-6,-5,0),
      new THREE.Vector3(0,5,0),
      new THREE.Vector3(6,-5,0),
      new THREE.Vector3(-6,-5,0)
    )

    triangle = new THREE.Line(triangleGeometry,lineMaterial)
    triangle.position.set(-20,-10,-500)
    @scene.add(triangle)

    triangle2 = new THREE.Line(triangleGeometry,lineMaterial)
    triangle2.position.set(20,-10,-500)
    @scene.add(triangle2)

    triangle3 = new THREE.Line(triangleGeometry,lineMaterial)
    triangle3.position.set(-20,10,-500)
    @scene.add(triangle3)

    triangle4 = new THREE.Line(triangleGeometry,lineMaterial)
    triangle4.position.set(20,10,-500)
    @scene.add(triangle4)

    animateFn = =>
      triangle.position.z += (50 - triangle.position.z)/30
      triangle2.position.z += (50 - triangle2.position.z)/30
      triangle3.position.z += (50 - triangle3.position.z)/30
      triangle4.position.z += (50 - triangle4.position.z)/30

      triangle.rotation.z -= .01
      triangle2.rotation.z -= .01
      triangle3.rotation.z += .01
      triangle4.rotation.z += .01

    anim1 = =>
      triangle.rotation.z += Math.PI/2
      triangle2.rotation.z += Math.PI/2
      triangle3.rotation.z -= Math.PI/2
      triangle4.rotation.z -= Math.PI/2
      lineMaterial.color.setHex(Math.random() * 0xffffff)

    inter = setInterval anim1, (@bpm)

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      clearInterval(inter)
      @scene.remove(triangle)
      @scene.remove(triangle2)
      @scene.remove(triangle3)
      @scene.remove(triangle4)
      cancelAnimationFrame(req)
      triangle1 = null
      triangle2 = null
      triangle3 = null
      triangle4 = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 2000

  minimalSphereMeshAnim: =>
    @camera.position.z = 50

    #ELEMENTS
    geometryintro = new THREE.SphereGeometry(15,20,10)
    materialintro = new THREE.MeshBasicMaterial({color:0xffffff, opacity:0, wireframe: true, wireframeLinewidth: 2, transparent: true})
    meshintro = new THREE.Mesh(geometryintro, materialintro)
    @scene.add(meshintro);
    meshintro.position.set(0,0,0)
    materialintro.opacity = 1
    materialintro.color.setHex(Math.random() * 0xffffff)
    meshintro.rotation.y = 0

    animateFn = =>
      meshintro.rotation.y += .01;
      materialintro.opacity += (0 - materialintro.opacity)/30

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(meshintro)
      cancelAnimationFrame(req)
      meshintro = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 2000

  explodingSphereAnim: =>
    @camera.position.z = 50

    #SPHERES
    geometry = new THREE.SphereGeometry(1, 80, 20)
    geometry2 = new THREE.SphereGeometry(15, 80, 20)
    material = new THREE.PointsMaterial(
      size: 1
      vertexColors: true
      transparent: true
      opacity: 1)

    material2 = new THREE.MeshBasicMaterial(
      transparent: true
      opacity: 0)
    colors = []
    i = 0
    while i < geometry.vertices.length
      colors[i] = new (THREE.Color)
      colors[i].setHSL 100, 100, 0
      # colors[i].setHSL(Math.random(),1,0.5);
      i++

    geometry.colors = colors
    geometry2.colors = colors
    mesh = new THREE.Points(geometry, material2)
    mesh.position.set 0, -20, 0
    mesh2 = new THREE.Points(geometry2, material)
    mesh2.sortParticles = true
    @scene.add(mesh)
    @scene.add(mesh2)

    animateFn= =>
      mesh.position.y += (25 - (mesh.position.y)) / 20
      mesh2.rotation.y += .005

      vertices = mesh2.geometry.vertices

      if mesh.position.y >= 15
        mesh2.rotation.x += Math.random() / 20 - .025
        mesh2.rotation.y += Math.random() / 20 - .025
        # mesh2.rotation.z += Math.random()/20-.025;
        mesh2.scale.x += (2 - (mesh2.scale.x)) / 20
        mesh2.scale.y += (2 - (mesh2.scale.y)) / 20
        mesh2.scale.z += (2 - (mesh2.scale.z)) / 20
        material.size += (.5 - (material.size)) / 20
        material.opacity += (0 - (material.opacity)) / 20
      i = 0
      while i < geometry.vertices.length
        if geometry2.vertices[i].y <= mesh.position.y
          geometry2.vertices[i].x -= Math.random() / 2 - .25
          geometry2.vertices[i].y -= Math.random() / 2 - .25
          geometry2.vertices[i].z -= Math.random() / 2 - .25
        # geometry2.vertices[i].y -= (Math.random()/5);
        # if (geometry2.vertices[i].y <= 0) {geometry2.vertices[i].y = 0};
        i++
      geometry2.verticesNeedUpdate = true
      geometry2.dynamic = true

    req = 0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(mesh)
      @scene.remove(mesh2)
      cancelAnimationFrame(req)
      mesh = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 1200

  splittingSphereTopAnim: =>
    @camera.position.z = 50

    geometry = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,Math.PI,Math.PI/2)

    colors = [];
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(100,100,0)

    geometry.colors = colors

    material = new THREE.PointsMaterial({size:1, vertexColors: true, transparent: true, opacity:1})

    mesh = new THREE.Points(geometry, material)
    mesh.position.set(0,0,0)

    geometry2 = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,0,Math.PI/2)
    geometry2.colors = colors
    vertices = mesh.geometry.vertices

    mesh2 = new THREE.Points(geometry2,material)
    mesh2.sortParticles = true
    @scene.add(mesh2)

    @scene.add(mesh)

    animateFn = =>
      mesh.rotation.y += .005;
      mesh2.scale.x += (1 - mesh2.scale.x)/50;
      mesh2.scale.y += (1 - mesh2.scale.y)/50;
      mesh2.scale.z += (1 - mesh2.scale.z)/50;

      vertices = mesh2.geometry.vertices;
      max = geometry.vertices.length - 1
      for i in [0..max]
        geometry2.vertices[i].y -= (Math.random()/5)
        if (geometry2.vertices[i].y <= 0)
          geometry2.vertices[i].y = 0

      geometry2.verticesNeedUpdate = true
      geometry2.dynamic = true

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(mesh)
      @scene.remove(mesh2)
      cancelAnimationFrame(req)
      mesh = null
      mesh2 = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 2600

  splittingSphereBottomAnim: =>
    @camera.position.z = 50

    geometry = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,0,Math.PI/2)

    colors = [];
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(100,100,0)

    geometry.colors = colors

    material = new THREE.PointsMaterial({size:1, vertexColors: true, transparent: true, opacity:1})

    mesh = new THREE.Points(geometry, material)
    mesh.position.set(0,0,0)

    geometry2 = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,Math.PI,Math.PI/2)
    geometry2.colors = colors
    vertices = mesh.geometry.vertices

    mesh2 = new THREE.Points(geometry2,material)
    mesh2.sortParticles = true
    @scene.add(mesh2)

    @scene.add(mesh)

    animateFn = =>
      mesh.rotation.y += .005;
      mesh2.scale.x += (1 - mesh2.scale.x)/50;
      mesh2.scale.y += (1 - mesh2.scale.y)/50;
      mesh2.scale.z += (1 - mesh2.scale.z)/50;

      vertices = mesh2.geometry.vertices
      max = geometry.vertices.length - 1
      for i in [0..max]
        geometry2.vertices[i].y -= (Math.random()/5)

      geometry2.verticesNeedUpdate = true
      geometry2.dynamic = true

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(mesh)
      @scene.remove(mesh2)
      cancelAnimationFrame(req)
      mesh = null
      mesh2 = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 2600

  sideSplittingSphereDownAnim: =>
    @camera.position.z = 50

    geometry = new THREE.SphereGeometry(15,80,20,0,Math.PI,0,Math.PI)

    colors = [];
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(100,100,0)

    geometry.colors = colors

    material = new THREE.PointsMaterial({size:1, vertexColors: true, transparent: true, opacity:1})

    mesh = new THREE.Points(geometry, material)
    mesh.position.set(0,0,0)

    geometry2 = new THREE.SphereGeometry(15,80,20,0,Math.PI,Math.PI,Math.PI)
    geometry2.colors = colors
    vertices = mesh.geometry.vertices

    mesh2 = new THREE.Points(geometry2,material)
    mesh2.sortParticles = true
    @scene.add(mesh2)

    @scene.add(mesh)

    animateFn = =>
      mesh.rotation.y += .01
      mesh2.rotation.y += .01
      mesh2.scale.x += (1 - mesh2.scale.x)/50
      mesh2.scale.y += (1 - mesh2.scale.y)/50
      mesh2.scale.z += (1 - mesh2.scale.z)/50

      vertices = mesh2.geometry.vertices
      max = geometry.vertices.length - 1
      for i in [0..max]
        geometry2.vertices[i].y -= (Math.random()/5)

      geometry2.verticesNeedUpdate = true
      geometry2.dynamic = true

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(mesh)
      @scene.remove(mesh2)
      cancelAnimationFrame(req)
      mesh = null
      mesh2 = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 2600

  sideSplittingSphereUpAnim: =>
    @camera.position.z = 50

    geometry = new THREE.SphereGeometry(15,80,20,0,Math.PI,0,Math.PI)

    colors = [];
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(100,100,0)

    geometry.colors = colors

    material = new THREE.PointsMaterial({size:1, vertexColors: true, transparent: true, opacity:1})

    mesh = new THREE.Points(geometry, material)
    mesh.position.set(0,0,0)

    geometry2 = new THREE.SphereGeometry(15,80,20,0,Math.PI,Math.PI,Math.PI)
    geometry2.colors = colors
    vertices = mesh.geometry.vertices

    mesh2 = new THREE.Points(geometry2,material)
    mesh2.sortParticles = true
    @scene.add(mesh2)

    @scene.add(mesh)

    animateFn = =>
      mesh.rotation.y -= .01
      mesh2.rotation.y -= .01
      mesh2.scale.x += (1 - mesh2.scale.x)/50
      mesh2.scale.y += (1 - mesh2.scale.y)/50
      mesh2.scale.z += (1 - mesh2.scale.z)/50

      vertices = mesh2.geometry.vertices
      max = geometry.vertices.length - 1
      for i in [0..max]
        geometry2.vertices[i].y += (Math.random()/5)

      geometry2.verticesNeedUpdate = true
      geometry2.dynamic = true

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(mesh)
      @scene.remove(mesh2)
      cancelAnimationFrame(req)
      mesh = null
      mesh2 = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 2600

  discoballAnim: =>
    @camera.position.z = 50

    geometry = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,Math.PI,Math.PI/2)

    colors = []
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(Math.random(),1,0.5)

    geometry.colors = colors

    material = new THREE.PointsMaterial({size:1, vertexColors: true, transparent: true, opacity:1})

    mesh = new THREE.Points(geometry, material);
    mesh.position.set(0,0,0);

    geometry2 = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,0,Math.PI/2);
    geometry2.colors = colors;
    vertices = mesh.geometry.vertices;
    topmesh = new THREE.Points(geometry2,material);
    topmesh.sortParticles = true;

    @scene.add(mesh)
    @scene.add(topmesh)

    topmesh.scale.x = 1.1;
    topmesh.scale.y = 1.1;
    topmesh.scale.z = 1.1;
    mesh.scale.x = 1.1;
    mesh.scale.y = 1.1;
    mesh.scale.z = 1.1;

    animateFn = =>
      mesh.rotation.y -= .005;
      topmesh.rotation.y += .005;
      topmesh.scale.x += (1 - topmesh.scale.x)/50;
      topmesh.scale.y += (1 - topmesh.scale.y)/50;
      topmesh.scale.z += (1 - topmesh.scale.z)/50;
      mesh.scale.x += (1 - mesh.scale.x)/50;
      mesh.scale.y += (1 - mesh.scale.y)/50;
      mesh.scale.z += (1 - mesh.scale.z)/50;

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(topmesh)
      @scene.remove(mesh)
      cancelAnimationFrame(req)
      topmesh = null
      mesh = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 800

  enhancedDiscoballAnim: =>
    @camera.position.z = 50

    geometry = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,Math.PI,Math.PI/2)

    colors = []
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(Math.random(),1,0.5)

    geometry.colors = colors

    material = new THREE.PointsMaterial({size:1, vertexColors: true, transparent: true, opacity:1})

    mesh = new THREE.Points(geometry, material);
    mesh.position.set(0,0,0);

    geometry2 = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,0,Math.PI/2);
    geometry2.colors = colors;
    vertices = mesh.geometry.vertices;
    topmesh = new THREE.Points(geometry2,material);
    topmesh.sortParticles = true;

    @scene.add(mesh);
    @scene.add(topmesh);

    geometry3 = new THREE.SphereGeometry(10,20,10);
    whitematerial = new THREE.MeshBasicMaterial({color:0xffffff, opacity:1, wireframe: true, wireframeLinewidth: 2, transparent: true});
    wiremesh = new THREE.Mesh(geometry3, whitematerial);
    @scene.add(wiremesh);

    topmesh.scale.x = 1.1;
    topmesh.scale.y = 1.1;
    topmesh.scale.z = 1.1;
    mesh.scale.x = 1.1;
    mesh.scale.y = 1.1;
    mesh.scale.z = 1.1;
    wiremesh.scale.x = .1;
    wiremesh.scale.y = .1;
    wiremesh.scale.z = .1;

    animateFn = =>
      mesh.rotation.y -= .005;
      topmesh.rotation.y += .005;
      topmesh.scale.x += (1 - topmesh.scale.x)/50;
      topmesh.scale.y += (1 - topmesh.scale.y)/50;
      topmesh.scale.z += (1 - topmesh.scale.z)/50;
      mesh.scale.x += (1 - mesh.scale.x)/50;
      mesh.scale.y += (1 - mesh.scale.y)/50;
      mesh.scale.z += (1 - mesh.scale.z)/50;
      wiremesh.scale.x += (1 - wiremesh.scale.x)/50;
      wiremesh.scale.y += (1 - wiremesh.scale.y)/50;
      wiremesh.scale.z += (1 - wiremesh.scale.z)/50;

    req =0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(topmesh)
      @scene.remove(mesh)
      @scene.remove(wiremesh)
      cancelAnimationFrame(req)
      topmesh = null
      mesh = null
      wiremesh = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 800

  spinningCircleZoomAnim: =>
    @camera.position.z = 50

    #ELEMENTS
    geometry = new THREE.RingGeometry(10, 20, 30, 20, 0, 4)
    material = new THREE.MeshBasicMaterial(
      color: 0x00000
      side: THREE.DoubleSide)

    mesh = new THREE.Mesh(geometry, material)
    @scene.add(mesh)
    mesh.position.z = -1000

    animateFn= =>
      mesh.position.z += (50 - (mesh.position.z)) / 10
      mesh.rotation.z += .7

    req = 0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(mesh)
      cancelAnimationFrame(req)
      mesh = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 1200

  logoAnim: =>
    @camera.position.z = 50

    theText = 'Synthery'
    text3d = new THREE.TextGeometry(theText,
      size: 5
      height: 5
      curveSegments: 0
      font: 'abel')
    text3d.computeBoundingBox()
    centerOffset = -0.5 * (text3d.boundingBox.max.x - (text3d.boundingBox.min.x))

    material = new THREE.MeshFaceMaterial([
      new THREE.MeshBasicMaterial(
        color: Math.random() * 0xffffff
        overdraw: 0.5),
      new THREE.MeshBasicMaterial(
        color: 0x000000
        overdraw: 0.5)
    ])
    text = new THREE.Mesh(text3d, material)
    text.position.x = centerOffset
    text.position.y = 0
    text.position.z = 0
    text.rotation.x = 0
    text.rotation.y = Math.PI * 2
    group = new (THREE.Group)
    group.add(text)
    @scene.add(group)

    animateFn = =>
      group.scale.x += (2-(group.scale.x))/20
      group.scale.y += (2-(group.scale.y))/20

    req = 0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(group)
      cancelAnimationFrame(req)
      group = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 1200

  madeWithJSAnim: =>
    @camera.position.z = 50

    theText = 'Made with JS'
    text3d = new THREE.TextGeometry(theText,
      size: 7
      height: 7
      curveSegments: 0
      font: 'abel')
    text3d.computeBoundingBox()
    centerOffset = -0.5 * (text3d.boundingBox.max.x - (text3d.boundingBox.min.x))

    material = new THREE.MeshFaceMaterial([
      new THREE.MeshBasicMaterial(
        color: 0xffffff
        overdraw: 0.5),
      new THREE.MeshBasicMaterial(
        color: 0x000000
        overdraw: 0.5)
    ])
    text = new THREE.Mesh(text3d, material)
    text.position.x = centerOffset
    text.position.y = 0
    text.position.z = 0
    text.rotation.x = 0
    text.rotation.y = Math.PI * 2
    group = new (THREE.Group)
    group.add(text)
    @scene.add(group)
    console.log(group.scale.x)
    console.log(group.scale.y)

    animateFn = =>
      group.rotation.x += Math.random() / 20 - .025
      group.rotation.y += Math.random() / 20 - .025

    req = 0
    render = =>
      req = requestAnimationFrame(render)
      animateFn()
      @renderer.render(@scene, @camera)

    callback = =>
      @scene.remove(group)
      cancelAnimationFrame(req)
      group = null
      @renderer.render(@scene, @camera)

    render()
    callbackTimeout = setTimeout callback, 1200

  ###SCENES ###

  flashToBlackAnim: =>
    @clearScene()
    @camera.position.z = 50

    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0x000000, side: THREE.BackSide })
    skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(skybox)

    @animateFn = =>
      skyboxMaterial.color.setHex(Math.random() * 0xffffff)

    callback = =>
      @scene.remove(skybox)
      skybox = null
      @renderer.render(@scene, @camera)

    @render()
    @callbackTimeout = setTimeout callback, 400

  randomBgColorsAnim: =>
    @clearScene()
    @camera.position.z = 50

    bskyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    @bskyboxMaterial = new THREE.MeshBasicMaterial({ color: 0xcccccc, side: THREE.BackSide })
    @bskyboxMaterial.color.setHex(Math.random() * 0xffffff)
    @bskybox = new THREE.Mesh(bskyboxGeometry, @bskyboxMaterial)
    @scene.add(@bskybox)

    anim1 = =>
      @bskyboxMaterial.color.setHex(Math.random() * 0xffffff)

    @inter = setInterval anim1, (@bpm*4)

    callback = =>
      @scene.remove(@bskybox)

    @render()

  enhancedRotatingCubeAnim: =>
    @clearScene()
    @camera.position.z = 50

    #ELEMENTS
    #SKYBOX
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0xcccccc, side: THREE.BackSide })
    skyboxMaterial.color.setHex(Math.random() * 0xffffff)
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    #CUBES
    geometry = new THREE.BoxGeometry(15,15,15)
    material = new THREE.MeshBasicMaterial({color: 0xff0000, opacity:0.5, transparent:true})
    @cube1 = new THREE.Mesh(geometry,material)
    @cube1.rotation.x = (Math.PI/3)
    @cube1.rotation.y = (Math.PI/3)
    @cube1.rotation.z = (Math.PI/3)
    @scene.add(@cube1)

    @boxes = []

    box =
      new THREE.Mesh(
        new THREE.PlaneGeometry(10,10),
        new THREE.MeshBasicMaterial({wireframe:true, color: 0xffffff, opacity: 1, transparent: true, wireframeLinewidth:2})
        )
    @scene.add(box)
    box.material.opacity = 1;
    box.position.set(80*Math.random()-40,50*Math.random()-25,20*Math.random()-10)
    @boxes.push(box);

    @animateFn = =>
      @cube1.rotation.x += .01
      @cube1.rotation.y += .02
      @cube1.rotation.z += .03
      @cube1.position.z += (0 - @cube1.position.z)/20
      max = @boxes.length - 1
      for i in [0.. max]
        @boxes[i].rotation.z += .05
        @boxes[i].material.opacity += (0 - @boxes[i].material.opacity)/20

    anim1 = =>
      skyboxMaterial.color.setHex(Math.random() * 0xffffff)
      material.color.setHex(Math.random() * 0xffffff)

    anim2 = =>
      @cube1.position.z = 10

    anim3 = =>
      box =
        new THREE.Mesh(
          new THREE.PlaneGeometry(10,10),
          new THREE.MeshBasicMaterial({wireframe:true, color: 0xffffff, opacity: 1, transparent: true, wireframeLinewidth:1})
          )
      @scene.add(box)
      box.material.opacity = 1;
      box.position.set(80*Math.random()-40,50*Math.random()-25,30*Math.random()-15)
      @boxes.push(box)

    @inter = setInterval anim1, (@bpm*4)
    @inter2 = setInterval anim2, (@bpm)
    @inter3 = setInterval anim3, (@bpm/8)

    # callbackStop = =>
    #   @scene.remove(@cube1)
    #   @scene.remove(@skybox)

    @render()
    # @callbackTimeout = setTimeout callbackStop, 400

  cubeAttackAnim: =>
    @clearScene()
    @camera.position.z = 50

    #ELEMENTS
    #SKYBOX
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0xcccccc, side: THREE.BackSide })
    skyboxMaterial.color.setHex(Math.random() * 0xffffff)
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    #CUBES
    geometry = new THREE.BoxGeometry(15,15,15)
    material = new THREE.MeshBasicMaterial({color: 0xff0000, opacity:0.5, transparent:true})
    @cube1 = new THREE.Mesh(geometry,material)
    @cube1.rotation.x = (Math.PI/3)
    @cube1.rotation.y = (Math.PI/3)
    @cube1.rotation.z = (Math.PI/3)
    @cube1.position.z = 30
    @scene.add(@cube1)

    @boxes = []

    box =
      new THREE.Mesh(
        new THREE.PlaneGeometry(10,10),
        new THREE.MeshBasicMaterial({wireframe:true, color: 0xffffff, opacity: 1, transparent: true, wireframeLinewidth:2})
        )
    @scene.add(box)
    box.material.opacity = 1;
    box.position.set(80*Math.random()-40,50*Math.random()-25,20*Math.random()-10)
    @boxes.push(box);

    @animateFn = =>
      @cube1.rotation.x += .01
      @cube1.rotation.y += .02
      @cube1.rotation.z += .03
      @cube1.position.z += (0 - @cube1.position.z)/20
      max = @boxes.length - 1
      for i in [0.. max]
        @boxes[i].rotation.z += .05
        @boxes[i].material.opacity += (0 - @boxes[i].material.opacity)/20

    anim1 = =>
      skyboxMaterial.color.setHex(Math.random() * 0xffffff)
      material.color.setHex(Math.random() * 0xffffff)

    anim2 = =>
      @cube1.position.z = 30

    anim3 = =>
      box =
        new THREE.Mesh(
          new THREE.PlaneGeometry(10,10),
          new THREE.MeshBasicMaterial({wireframe:true, color: 0xffffff, opacity: 1, transparent: true, wireframeLinewidth:1})
          )
      @scene.add(box)
      box.material.opacity = 1;
      box.position.set(80*Math.random()-40,50*Math.random()-25,30*Math.random()-15)
      @boxes.push(box)

    @inter = setInterval anim1, (@bpm*4)
    @inter2 = setInterval anim2, (@bpm)
    @inter3 = setInterval anim3, (@bpm/8)

    callback = =>
      @scene.remove(@cube1)
      @scene.remove(@skybox)

    @render()
    # @callbackTimeout = setTimeout callback, 400

  enhancedRotatingSphereMeshAnim: =>
    @clearScene()
    @camera.position.z = 50

    #ELEMENTS
    #SKYBOX
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0xcccccc, side: THREE.BackSide })
    skyboxMaterial.color.setHex(Math.random() * 0xffffff)
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    #SPHERES
    sphereMaterial = new THREE.MeshBasicMaterial({color:0xff0000, wireframe: true, wireframeLinewidth:9, transparent: true, opacity: 0.5})
    sphereGeometry = new THREE.SphereGeometry( 15,8,8,0,6.3,3,2.5 )

    @sphere = new THREE.Mesh( sphereGeometry, sphereMaterial )
    @sphere.position.set(0,-15,0)
    @scene.add( @sphere )

    @sphere2 = new THREE.Mesh(sphereGeometry,sphereMaterial)
    @sphere2.position.set(0,15,0)
    @sphere2.rotation.z = Math.PI
    @scene.add(@sphere2);

    @animateFn = =>

      @sphere.rotation.y +=.04
      @sphere2.rotation.y += .04
      @sphere.position.z += (40 - @sphere.position.z)/30
      @sphere2.position.z += (40 - @sphere2.position.z)/30

    anim1 = =>
      skyboxMaterial.color.setHex(Math.random() * 0xffffff)
      sphereMaterial.color.setHex(Math.random() * 0xffffff)
      @sphere.position.z -= 10
      @sphere2.position.z -= 10

    anim2 = =>
      @sphere.position.z = 0
      @sphere2.position.z = 0

    @inter = setInterval anim1, (@bpm)
    @inter2 = setInterval anim2, (@bpm*4)

    # @animateSquaresFn

    callback = =>
      @scene.remove(@sphere)
      @scene.remove(@sphere2)
      @scene.remove(@skybox)

    @render()
    # @callbackTimeout = setTimeout callback, 400

  enhancedMovingTrianglesAnim: =>
    @clearScene()
    @camera.position.z = -20

    #ELEMENTS
    #SKYBOX
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0xcccccc, side: THREE.BackSide })
    skyboxMaterial.color.setHex(Math.random() * 0xffffff)
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    #TRIANGLES
    lineMaterial = new THREE.LineBasicMaterial({
      color:0xff0000, linewidth: 50, transparent:true
    })

    triangleGeometry = new THREE.Geometry()

    triangleGeometry.vertices.push(
      new THREE.Vector3(-6,-5,0),
      new THREE.Vector3(0,5,0),
      new THREE.Vector3(6,-5,0),
      new THREE.Vector3(-6,-5,0)
    )

    @triangle = new THREE.Line(triangleGeometry,lineMaterial)
    @triangle.position.set(-20,-10,-1000)
    @scene.add(@triangle)

    @triangle2 = new THREE.Line(triangleGeometry,lineMaterial)
    @triangle2.position.set(20,-10,-1000)
    @scene.add(@triangle2)

    @triangle3 = new THREE.Line(triangleGeometry,lineMaterial)
    @triangle3.position.set(-20,10,-1000)
    @scene.add(@triangle3)

    @triangle4 = new THREE.Line(triangleGeometry,lineMaterial)
    @triangle4.position.set(20,10,-1000)
    @scene.add(@triangle4)

    @animateFn = =>
      @triangle.position.z += (0 - @triangle.position.z)/30
      @triangle2.position.z += (0 - @triangle2.position.z)/30
      @triangle3.position.z += (0 - @triangle3.position.z)/30
      @triangle4.position.z += (0 - @triangle4.position.z)/30

      @triangle.rotation.z -= .01
      @triangle2.rotation.z -= .01
      @triangle3.rotation.z += .01
      @triangle4.rotation.z += .01

    anim1 = =>
      @triangle.rotation.z += Math.PI/2
      @triangle2.rotation.z += Math.PI/2
      @triangle3.rotation.z -= Math.PI/2
      @triangle4.rotation.z -= Math.PI/2
      lineMaterial.color.setHex(Math.random() * 0xffffff)
      skyboxMaterial.color.setHex(Math.random() * 0xffffff)
      @triangle.position.z = @triangle.position.z - 100
      @triangle2.position.z = @triangle2.position.z - 100
      @triangle3.position.z = @triangle3.position.z - 100
      @triangle4.position.z = @triangle4.position.z - 100

    anim2 = =>
      @triangle.position.z = -1000
      @triangle2.position.z = -1000
      @triangle3.position.z = -1000
      @triangle4.position.z = -1000

    @inter = setInterval anim1, (@bpm)
    @inter2 = setInterval anim2, (@bpm*8)

    # @animateSquaresFn

    callback = =>
      @scene.remove(@triangle)
      @scene.remove(@triangle2)
      @scene.remove(@triangle3)
      @scene.remove(@triangle4)
      @scene.remove(@skybox)

    @render()
    # @callbackTimeout = setTimeout callback, 400

  dancingSphereAnim: =>
    @clearScene()
    @camera.position.z = 50
    #skybox
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0xffffff, side: THREE.BackSide })
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    geometry = new THREE.SphereGeometry(15,80,20,0)

    material = new THREE.ParticleBasicMaterial({size:1.5, vertexColors: true, transparent: true, opacity:0.7})
    @mesh2 = new THREE.ParticleSystem(geometry, material)

    @scene.add(@mesh2)

    colors = []
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(0,0,0)

    geometry.colors = colors

    @mesh2.scale.x = 0.8
    @mesh2.scale.y = 0.8
    @mesh2.scale.z = 0.8
    skyboxMaterial.color.setHex(Math.random() * 0xffffff)

    @animateFn = =>
      @mesh2.rotation.y -= .01
      @mesh2.scale.x += (1 - @mesh2.scale.x)/20
      @mesh2.scale.y += (1 - @mesh2.scale.y)/20
      @mesh2.scale.z += (1 - @mesh2.scale.z)/20

    anim1 = =>
      @mesh2.scale.x = 0.8
      @mesh2.scale.y = 0.8
      @mesh2.scale.z = 0.8
      skyboxMaterial.color.setHex(Math.random() * 0xffffff)

    @inter = setInterval anim1, (@bpm)

    callback = =>
      @scene.remove(@mesh2)
      @scene.remove(@skybox)

    @render()
    # @callbackTimeout = setTimeout callback, 400

  trippyDancingSphereAnim: =>
    @clearScene()
    @camera.position.z = 50
    #skybox
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0x333333, side: THREE.BackSide })
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    geometry = new THREE.SphereGeometry(15,80,20)
    material = new THREE.ParticleBasicMaterial({size:1.5, vertexColors: true, transparent: true, opacity:0.7});
    material2 = new THREE.ParticleBasicMaterial({size:5, vertexColors: true, transparent: true, opacity:0.7});
    @mesh = new THREE.ParticleSystem(geometry, material);
    @mesh2 = new THREE.ParticleSystem(geometry, material);
    @starmesh = new THREE.ParticleSystem(geometry, material2);

    @scene.add(@mesh);
    @scene.add(@mesh2);
    @scene.add(@starmesh);
    @mesh.position.set(0,0,0)
    @starmesh.scale.x = 10
    @starmesh.scale.y = 10
    @starmesh.scale.z = 10

    @mesh.scale.x = 1.5
    @mesh.scale.y = 1.5
    @mesh.scale.z = 1.5

    @mesh2.scale.x = 0.5
    @mesh2.scale.y = 0.5
    @mesh2.scale.z = 0.5

    colors = []
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(Math.random(),1,0.5)

    geometry.colors = colors

    @animateFn = =>
      @mesh.rotation.y += .01;
      @mesh.scale.x += (1 - @mesh.scale.x)/20;
      @mesh.scale.y += (1 - @mesh.scale.y)/20;
      @mesh.scale.z += (1 - @mesh.scale.z)/20;

      @mesh2.rotation.y -= .01;
      @mesh2.scale.x += (1 - @mesh2.scale.x)/20;
      @mesh2.scale.y += (1 - @mesh2.scale.y)/20;
      @mesh2.scale.z += (1 - @mesh2.scale.z)/20;

      @mesh.rotation.z += .01;
      @mesh2.rotation.z -= .01;
      @mesh.rotation.x += .01;
      @mesh2.rotation.x -= .01;

      @starmesh.rotation.x += .001;
      @starmesh.rotation.y += .002;
      @starmesh.rotation.z += .0015;

    anim1 = =>
      @mesh.scale.x = 1.5
      @mesh.scale.y = 1.5
      @mesh.scale.z = 1.5

      @mesh2.scale.x = 0.5
      @mesh2.scale.y = 0.5
      @mesh2.scale.z = 0.5

    @inter = setInterval anim1, (@bpm)

    callback = =>
      @scene.remove(@starmesh)
      @scene.remove(@mesh)
      @scene.remove(@mesh2)
      @scene.remove(@skybox)

    @render()
    # @callbackTimeout = setTimeout callback, 400

  trippyDancingSphereWithColorsAnim: =>
    @clearScene()
    @camera.position.z = 50
    #skybox
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0x333333, side: THREE.BackSide })
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    geometry = new THREE.SphereGeometry(15,80,20)
    material = new THREE.ParticleBasicMaterial({size:1.5, vertexColors: true, transparent: true, opacity:0.7});
    material2 = new THREE.ParticleBasicMaterial({size:15, color: 0xffffff, transparent: true, opacity:0.7});
    @mesh = new THREE.ParticleSystem(geometry, material);
    @mesh2 = new THREE.ParticleSystem(geometry, material);
    @starmesh = new THREE.ParticleSystem(geometry, material2);

    @scene.add(@mesh);
    @scene.add(@mesh2);
    @scene.add(@starmesh);
    @mesh.position.set(0,0,0)
    @starmesh.scale.x = 10
    @starmesh.scale.y = 10
    @starmesh.scale.z = 10

    @mesh.scale.x = 1.5
    @mesh.scale.y = 1.5
    @mesh.scale.z = 1.5

    @mesh2.scale.x = 0.5
    @mesh2.scale.y = 0.5
    @mesh2.scale.z = 0.5

    skyboxMaterial.color.setHex(Math.random() * 0xffffff)

    colors = []
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(Math.random(),1,0.5)

    geometry.colors = colors

    @animateFn = =>
      @mesh.rotation.y += .01;
      @mesh.scale.x += (1 - @mesh.scale.x)/20;
      @mesh.scale.y += (1 - @mesh.scale.y)/20;
      @mesh.scale.z += (1 - @mesh.scale.z)/20;

      @mesh2.rotation.y -= .01;
      @mesh2.scale.x += (1 - @mesh2.scale.x)/20;
      @mesh2.scale.y += (1 - @mesh2.scale.y)/20;
      @mesh2.scale.z += (1 - @mesh2.scale.z)/20;

      @mesh.rotation.z += .01;
      @mesh2.rotation.z -= .01;
      @mesh.rotation.x += .01;
      @mesh2.rotation.x -= .01;

      @starmesh.rotation.x += .001;
      @starmesh.rotation.y += .002;
      @starmesh.rotation.z += .0015;

    anim1 = =>
      @mesh.scale.x = 1.5
      @mesh.scale.y = 1.5
      @mesh.scale.z = 1.5

      @mesh2.scale.x = 0.5
      @mesh2.scale.y = 0.5
      @mesh2.scale.z = 0.5

      skyboxMaterial.color.setHex(Math.random() * 0xffffff)

    @inter = setInterval anim1, (@bpm)

    callback = =>
      @scene.remove(@starmesh)
      @scene.remove(@mesh)
      @scene.remove(@mesh2)
      @scene.remove(@skybox)

    @render()
    # @callbackTimeout = setTimeout callback, 400

  starrySkiesAnim: =>
    @clearScene()
    @camera.position.z = 50

    #skybox
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0x333333, side: THREE.BackSide })
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    geometry = new THREE.SphereGeometry(15,80,50);
    material = new THREE.ParticleBasicMaterial({size:1, color: 0xffffff, transparent: true, opacity:0.7});
    @mesh = new THREE.ParticleSystem(geometry, material);
    @mesh2 = new THREE.ParticleSystem(geometry, material);

    @scene.add(@mesh);
    @scene.add(@mesh2);
    @mesh.scale.x = 5;
    @mesh.scale.y = 5;
    @mesh.scale.z = 5;
    @mesh2.scale.x = 10;
    @mesh2.scale.y = 10;
    @mesh2.scale.z = 10;

    colors = []
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color();
      colors[i].setHSL(Math.random(),1,0.5)

    geometry.colors = colors;

    @animateFn = =>
      @mesh.rotation.x += .001;
      @mesh.rotation.y += .002;
      @mesh.rotation.z += .005;
      @mesh2.rotation.x -= .005;
      @mesh2.rotation.y -= .005;
      @mesh2.rotation.z -= .005;

    callback = =>
      @scene.remove(@mesh)
      @scene.remove(@mesh2)
      @scene.remove(@skybox)

    @render()
    # @callbackTimeout = setTimeout callback, 400

  confettiAnim: =>
    @clearScene()
    @camera.position.z = 50

    #skybox
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0x333333, side: THREE.BackSide })
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    #SPHERES
    geometry = new THREE.SphereGeometry(1, 80, 20)
    geometry2 = new THREE.SphereGeometry(15, 80, 20)
    material = new THREE.PointsMaterial(
      size: 1
      vertexColors: true
      transparent: true
      opacity: 1)

    material2 = new THREE.MeshBasicMaterial(
      transparent: true
      opacity: 0)
    colors = []
    i = 0
    while i < geometry.vertices.length
      colors[i] = new (THREE.Color)
      # colors[i].setHSL 100, 100, 0
      colors[i].setHSL(Math.random(),1,0.5);
      i++

    geometry.colors = colors
    geometry2.colors = colors
    mesh = new THREE.Points(geometry, material2)
    mesh.position.set 0, -20, 0
    mesh2 = new THREE.Points(geometry2, material)
    mesh2.sortParticles = true
    @scene.add(mesh)
    @scene.add(mesh2)

    skyboxMaterial.color.setHex(Math.random() * 0xffffff)

    @animateFn= =>
      # mesh.position.y += (25 - (mesh.position.y)) / 20
      mesh2.rotation.y += .005

      vertices = mesh2.geometry.vertices

      # if mesh.position.y >= 15
      mesh2.rotation.x += Math.random() / 20 - .025
      mesh2.rotation.y += Math.random() / 20 - .025
      mesh2.rotation.z += Math.random() /20-.025;

      mesh2.scale.x += (2 - (mesh2.scale.x)) / 20
      mesh2.scale.y += (2 - (mesh2.scale.y)) / 20
      mesh2.scale.z += (2 - (mesh2.scale.z)) / 20
      material.size += (.5 - (material.size)) / 20
      # material.opacity += (0 - (material.opacity)) / 20

      i = 0
      while i < geometry.vertices.length
        geometry2.vertices[i].x -= Math.random() / 2 - .25
        geometry2.vertices[i].y -= Math.random() / 2 - .25
        geometry2.vertices[i].z -= Math.random() / 2 - .25
        i++
      geometry2.verticesNeedUpdate = true
      geometry2.dynamic = true

    anim1 = =>
      mesh2.scale.x = 0.5
      mesh2.scale.y = 0.5
      mesh2.scale.z = 0.5
      material.size = 1

    anim2 = =>
      skyboxMaterial.color.setHex(Math.random() * 0xffffff)

    @inter = setInterval anim1, (@bpm)
    @inter2 = setInterval anim2, (@bpm*4)

    @render()

  enhancedDiscoballOnStarsAnim: =>
    @clearScene()
    @camera.position.z = 50

    #skybox
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0x333333, side: THREE.BackSide })
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    @scene.add(@skybox)

    geometry = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,Math.PI,Math.PI/2)

    colors = []
    max = geometry.vertices.length - 1
    for i in [0..max]
      colors[i] = new THREE.Color()
      colors[i].setHSL(Math.random(),1,0.5)

    geometry.colors = colors

    material = new THREE.PointsMaterial({size:1, vertexColors: true, transparent: true, opacity:1})

    @mesh = new THREE.Points(geometry, material);
    @mesh.position.set(0,0,0);

    geometry2 = new THREE.SphereGeometry(15,80,20,0,2*Math.PI,0,Math.PI/2);
    geometry2.colors = colors;
    vertices = @mesh.geometry.vertices;
    @topmesh = new THREE.Points(geometry2,material);
    @topmesh.sortParticles = true;

    @scene.add(@mesh);
    @scene.add(@topmesh);

    geometry3 = new THREE.SphereGeometry(10,20,10);
    whitematerial = new THREE.MeshBasicMaterial({color:0xffffff, opacity:1, wireframe: true, wireframeLinewidth: 2, transparent: true});
    @wiremesh = new THREE.Mesh(geometry3, whitematerial);
    @scene.add(@wiremesh);
    @wiremesh.scale.x = 0.1;
    @wiremesh.scale.y = 0.1;
    @wiremesh.scale.z = 0.1;

    material3 = new THREE.PointsMaterial({size:1, color: 0xffffff, transparent: true, opacity:1});
    @starmesh = new THREE.Points(geometry,material3);
    @scene.add(@starmesh);
    @starmesh.scale.x = 10;
    @starmesh.scale.y = 10;
    @starmesh.scale.z = 10;

    @topmesh.scale.x = 1.1;
    @topmesh.scale.y = 1.1;
    @topmesh.scale.z = 1.1;
    @mesh.scale.x = 1.1;
    @mesh.scale.y = 1.1;
    @mesh.scale.z = 1.1;
    @wiremesh.scale.x = .1;
    @wiremesh.scale.y = .1;
    @wiremesh.scale.z = .1;

    @animateFn = =>
      @mesh.rotation.y -= .005;
      @topmesh.rotation.y += .005;
      @topmesh.scale.x += (1 - @topmesh.scale.x)/50;
      @topmesh.scale.y += (1 - @topmesh.scale.y)/50;
      @topmesh.scale.z += (1 - @topmesh.scale.z)/50;
      @mesh.scale.x += (1 - @mesh.scale.x)/50;
      @mesh.scale.y += (1 - @mesh.scale.y)/50;
      @mesh.scale.z += (1 - @mesh.scale.z)/50;
      @wiremesh.scale.x += (1 - @wiremesh.scale.x)/50;
      @wiremesh.scale.y += (1 - @wiremesh.scale.y)/50;
      @wiremesh.scale.z += (1 - @wiremesh.scale.z)/50;

      @starmesh.rotation.x += .001;
      @starmesh.rotation.y += .002;
      @starmesh.rotation.z += .005;

    anim1 = =>
      @topmesh.scale.x = 1.1;
      @topmesh.scale.y = 1.1;
      @topmesh.scale.z = 1.1;
      @mesh.scale.x = 1.1;
      @mesh.scale.y = 1.1;
      @mesh.scale.z = 1.1;
      @wiremesh.scale.x = .1;
      @wiremesh.scale.y = .1;
      @wiremesh.scale.z = .1;

    @inter = setInterval anim1, (@bpm)

    callback = =>
      @scene.remove(@starmesh)
      @scene.remove(@topmesh)
      @scene.remove(@mesh)
      @scene.remove(@wiremesh)
      @scene.remove(@skybox)

    @render()
    # @callbackTimeout = setTimeout callback, 400

  radioactiveAnim: =>
    @clearScene()
    @camera.position.z = 50

    #skybox
    skyboxGeometry = new THREE.CubeGeometry(10000, 10000, 10000)
    skyboxMaterial = new THREE.MeshBasicMaterial({ color: 0x333333, side: THREE.BackSide })
    @skybox = new THREE.Mesh(skyboxGeometry, skyboxMaterial)
    skyboxMaterial.color.setHex(0xffdf43)
    isYellow = true

    @scene.add(@skybox)

    #ELEMENTS
    geometry = new THREE.RingGeometry(10, 20, 30, 20, 0, 4)
    material = new THREE.MeshBasicMaterial(
      color: 0x00000
      side: THREE.DoubleSide)

    mesh = new THREE.Mesh(geometry, material)
    mesh3 = new THREE.Mesh(geometry, material)

    @scene.add(mesh)
    @scene.add(mesh3)
    mesh.position.z = -1000
    mesh3.position.z = -200

    @animateFn= =>
      mesh.position.z += (50 - (mesh.position.z)) / 10
      mesh.rotation.z += .6
      mesh3.position.z += (50 - (mesh3.position.z)) / 10
      mesh3.rotation.z += .6

    anim1 = =>
      mesh.position.z = -1000
      mesh3.position.z = -200

    anim2 = =>
      if isYellow
        skyboxMaterial.color.setHex(0x2e28c3)
        material.color.setHex(0xc01ccf)
        isYellow = false
      else
        skyboxMaterial.color.setHex(0xffdf43)
        material.color.setHex(0x000000)
        isYellow = true

    @inter = setInterval anim1, (@bpm)
    @inter2 = setInterval anim2, (@bpm*2)

    @render()

  linesphereAnim: =>
    @clearScene()
    parameters = [ [ 0.0125, 0xff7700, 1, 2 ], [ 0.025, 0xff9900, 1, 1 ], [ 0.0375, 0xffaa00, 0.75, 1 ], [ 0.05, 0xffaa00, 0.5, 1 ], [ 0.0625, 0x000833, 0.8, 1 ]]
    geometry = @createGeometry()
    # @camera = new THREE.PerspectiveCamera( 80, @SCREEN_WIDTH / @SCREEN_HEIGHT, 1, 3000 )
    @camera.position.z = 50

    @objects = []
    for i in [0...parameters.length]
      p = parameters[ i ]
      material = new THREE.LineBasicMaterial( { color: p[ 1 ], opacity: p[ 2 ], linewidth: p[ 3 ] } )

      line = new THREE.LineSegments( geometry, material )
      line.scale.x = line.scale.y = line.scale.z = p[ 0 ]
      line.originalScale = p[ 0 ]
      line.rotation.y = Math.random() * Math.PI
      line.updateMatrix()
      # line.geometry = geometry
      @scene.add(line)
      @objects.push(line)

    @animateFn = =>
      time = Date.now() * 0.0007
      i = 0
      while i < @scene.children.length
        object = @scene.children[i]
        if object instanceof THREE.Line
          object.rotation.y = time * (if i < 4 then i + 1 else -(i + 1))

          if i < 5
            object.scale.x = object.scale.y = object.scale.z = object.originalScale += ((((i / 5 + 1) * (1.5))/30) - object.originalScale)/20
        i++

    anim1 = =>
      i = 0
      while i < 5
        object = @scene.children[i]
        if object instanceof THREE.Line
            object.scale.x = object.scale.y = object.scale.z = object.originalScale = parameters[i][0]
        i++

    @inter = setInterval anim1, (@bpm)
    @render()


  ### HELPER ###

  createGeometry: =>

    geometry = new THREE.Geometry()
    r = 450
    for i in [1..1500]
      vertex1 = new THREE.Vector3()
      vertex1.x = Math.random() * 2 - 1
      vertex1.y = Math.random() * 2 - 1
      vertex1.z = Math.random() * 2 - 1
      vertex1.normalize()
      vertex1.multiplyScalar(r )

      vertex2 = vertex1.clone()
      vertex2.multiplyScalar( Math.random() * 0.09 + 1 )

      geometry.vertices.push( vertex1 )
      geometry.vertices.push( vertex2 )

    return geometry


  ###
  RENDER AND CLEAR METHODS
  ###
  render: =>
    if @stopping
      @renderer.render(@scene, @camera)
    else
      @request = requestAnimationFrame(@render)

      @animateFn()
      @renderer.render(@scene, @camera)

  showCanvas: =>
    $("#visuals").show()
    $("#fullscreen-visuals").show()

    $("#gif-wrapper").hide()
    $("#fullscreen-gif-animator").hide()

  clearScene: =>
    @stopping = true
    @showCanvas()
    cancelAnimationFrame(@request)
    clearTimeout(@callbackTimeout) if @callbackTimeout
    @callbackTimeout = null
    clearInterval(@inter)
    clearInterval(@inter2)
    clearInterval(@inter3)
    @scene = new THREE.Scene()
    @stopping = false

module.exports = Animations
