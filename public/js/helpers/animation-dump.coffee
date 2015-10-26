###
  LINESPHERE ANIMATION
  ###

  linesphereAnim: =>
    @clearScene()
    parameters = [ [ 0.25, 0xff7700, 1, 2 ], [ 0.5, 0xff9900, 1, 1 ], [ 0.75, 0xffaa00, 0.75, 1 ], [ 1, 0xffaa00, 0.5, 1 ], [ 1.25, 0x000833, 0.8, 1 ]]
    geometry = @createGeometry()
    # @camera = new THREE.PerspectiveCamera( 80, @SCREEN_WIDTH / @SCREEN_HEIGHT, 1, 3000 )
    @camera.position.z = 1000

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

    # callback = =>
    #   geometry = @createGeometry()

    #   fn = (object) =>
    #     if (object instanceof THREE.Line)
    #       object.geometry.dispose()
    #       object.geometry = geometry
    #   console.log("creating geo interval")

    #   @scene.traverse(fn)

    # ireq = setInterval callback, 100

    @animateFn = =>
      time = Date.now() * 0.0007
      i = 0
      while i < @scene.children.length
        object = @scene.children[i]
        if object instanceof THREE.Line
          object.rotation.y = time * (if i < 4 then i + 1 else -(i + 1))

        if i < 5
          object.scale.x = object.scale.y = object.scale.z = object.originalScale * (i / 5 + 1) * (1 + 0.5 * Math.sin(7 * time))
        i++

    stopAnimation = =>
      @scene.remove(@objects[i]) for i in [0..4]
      # clearInterval(ireq)

    @render()
    @callbackTimeout = setTimeout stopAnimation, 400

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
  RANDOM MOVING POINTS
  ###
  squareparticlesAnim: =>
    @clearScene()
    @scene.fog = new THREE.FogExp2( 0x000000, 0.0007 )

    geometry = new THREE.Geometry()

    for i in [0..10000]
      vertex = new THREE.Vector3()
      vertex.x = Math.random() * 2000 - 1000;
      vertex.y = Math.random() * 2000 - 1000;
      vertex.z = Math.random() * 2000 - 1000;

      geometry.vertices.push(vertex);

    parameters = [
      [ [1, 1, 0.5], 5 ],
      [ [0.95, 1, 0.5], 4 ],
      [ [0.90, 1, 0.5], 3 ],
      [ [0.85, 1, 0.5], 2 ],
      [ [0.80, 1, 0.5], 1 ]
    ]

    @objects = []
    materials = []
    for k in [0...parameters.length]
      color = parameters[k][0];
      size  = parameters[k][1];

      materials[k] = new THREE.PointsMaterial({ size: size });

      particles = new THREE.Points(geometry, materials[k]);

      particles.rotation.x = Math.random() * 6;
      particles.rotation.y = Math.random() * 6;
      particles.rotation.z = Math.random() * 6;

      @scene.add(particles);
      @objects.push(particles)

    @animateFn = =>
      console.log(@scene.children.length)
      time = Date.now() * 0.0005;

      i = 0
      while i < @scene.children.length
        object = @scene.children[i]
        if object instanceof THREE.Points
          object.rotation.y = time * ( i < 4 ? i + 1 : - ( i + 1 ) );

        i++

      i = 0
      while i < materials.length
        color = parameters[i][0]
        h = ( 360 * ( color[0] + time ) % 360 ) / 360;
        materials[i].color.setHSL( h, color[1], color[2] )
        i++

    stopAnimation = =>
      for j in [0...@objects.length]
        @scene.remove(@objects[j])
      @scene.fog=null
      console.log(@scene.children)

    @callbackTimeout = setTimeout stopAnimation, 400
