module.exports =
  steps: [
    {
      element: '#settings'
      title: 'MIDI Device Settings'
      content: 'This is where all your MIDI devices are listed. Pick one from the list or connect a new device and refresh the page'
      placement: 'bottom'
    }
    {
      element: '#map-profile'
      title: 'Device Profiles'
      content: 'This is where you can see your previously saved profiles or create a new one. This is where you map a MIDI press to an animation'
      placement: 'right'
    }
    {
      element: '#animcanvas'
      title: 'Animation Canvas'
      content: 'You can preview animations here. Click on the full screen button on the bottom right of the canvas to expand this'
      placement: 'left'
    }
  ]
