module.exports =

#TODO: Animations should be connected to model
#temporary animations generator

  generateAnimation: (canvas, self) ->
    #number between 1 and 3
    num = Math.floor((Math.random() * 3) + 1)

    switch num
      when 1
        @rectflash(canvas, self)
      when 2
        @circleslide(canvas, self)
      when 3
        @linerandom(canvas, self)
    return


  #---- Blue Rectangle Flash
  rectflash: (canvas, self) ->
    bg1 = canvas.makeRectangle(canvas.width / 2, canvas.height / 2, canvas.width, canvas.height)

    #draw rectangle convering entire frame
    bg1.fill = '#42e8fe'
    bg1.noStroke()
    canvas.bind('update', (frameCount) ->
      if bg1.opacity > 0
        bg1.opacity -= 0.1
      return
    ).play()

    callback = ->
      canvas.remove bg1
      canvas.pause()

    setTimeout callback.bind(self), 300

  #---- Orange Circle Slide  
  circleslide: (canvas, self) ->
    circle2radius = 0.3 * canvas.height

    #set radius of circle
    circle2 = canvas.makeCircle(-(0.3 * canvas.width), canvas.height / 2, circle2radius)

    #draw circle out of frame
    circle2.fill = '#ffaf47'
    circle2.noStroke()

    canvas.bind('update', (frameCount) ->
      circlet1 = (canvas.width / 2 - (circle2.translation.x)) * 0.2

      #set tweening variable t1 for when circle approaches halfway mark
      circlet2 = (canvas.width + circle2radius - (circle2.translation.x)) * 0.2

      #set tweening variable t2 for when circle has passed halfway mark
      if circle2.translation.x < 0.999 * canvas.width / 2
        #before circle hits halfway mark
        circle2.scale += 0.0004 * circlet1
        circle2.translation.x += circlet1
      else
        #after circle hits halfway mark
        circle2.translation.x += circlet2
        circle2.scale -= 0.0004 * circlet2
      return
    ).play()

    callback = ->
      canvas.remove circle2
      canvas.pause()

    setTimeout callback.bind(self), 1500

  #---- Green Lines
  linerandom: (canvas, self) ->
    line3x = Math.random() * canvas.width

    #randomize x position of line 
    line3 = canvas.makeLine(line3x, -0.5 * canvas.height, line3x, 0)

    #draw line out of frame
    line3.stroke = '#2ecc71'
    line3.linewidth = Math.random() * 30

    canvas.bind('update', (frameCount) ->
      #move line downwards with tweening variable t
      line3t = (1.5 * canvas.height - (line3.translation.y)) * 0.1
      line3.translation.y += line3t
      line3.linewidth += 0.05
      return
    ).play()

    callback = ->
      canvas.remove line3
      canvas.pause()

    setTimeout callback.bind(self), 1000

