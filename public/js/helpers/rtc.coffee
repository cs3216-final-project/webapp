Firebase = require 'firebase'

class RTC
  ### WebRTC Demo
  # Allows two clients to connect via WebRTC with Data Channels
  # Uses Firebase as a signalling server
  # http://fosterelli.co/getting-started-with-webrtc-data-channels.html 
  ###

  ### == Announcement Channel Functions == ###

  # Announce our arrival to the announcement channel
  sendAnnounceChannelMessage: =>
    @announceChannel.remove( () =>
      @announceChannel.push ({
        sharedKey: @sharedKey
        id: @id})
      console.log 'Announced our sharedKey is ' + @sharedKey
      console.log 'Announced our ID is ' + @id
    )

  # Handle an incoming message on the announcement channel
  handleAnnounceChannelMessage: (snapshot) =>
    message = snapshot.val()
    if message.id != @id and message.sharedKey == @sharedKey
      console.log 'Discovered matching announcement from ' + message.id
      @remote = message.id
      @initiateWebRTCState()
      @connect()

  ### == Signal Channel Functions == ###

  # Send a message to the remote client via Firebase
  sendSignalChannelMessage: (message) =>
    message.sender = @id
    @database.child('messages').child(@remote).push message

  # Handle a WebRTC offer request from a remote client
  handleOfferSignal: (message) =>
    @running = true
    @remote = message.sender
    @initiateWebRTCState()
    @startSendingCandidates()
    @peerConnection.setRemoteDescription new RTCSessionDescription(message)
    @peerConnection.createAnswer (sessionDescription) =>
      console.log 'Sending answer to ' + message.sender
      @peerConnection.setLocalDescription sessionDescription
      @sendSignalChannelMessage sessionDescription.toJSON()

  # Handle a WebRTC answer response to our offer we gave the remote client
  handleAnswerSignal: (message) =>
    @peerConnection.setRemoteDescription new RTCSessionDescription(message)

  # Handle an ICE candidate notification from the remote client
  handleCandidateSignal: (message) =>
    candidate = new RTCIceCandidate(message)
    @peerConnection.addIceCandidate candidate

  # This is the general handler for a message from our remote client
  handleSignalChannelMessage: (snapshot) =>
    message = snapshot.val()
    sender = message.sender
    type = message.type
    console.log 'Recieved a \'' + type + '\' signal from ' + sender
    if type == 'offer'
      @handleOfferSignal message
    else if type == 'answer'
      @handleAnswerSignal message
    else if type == 'candidate' and @running
      @handleCandidateSignal message

  ### == ICE Candidate Functions == ###

  # Add listener functions to ICE Candidate events
  startSendingCandidates: =>
    @peerConnection.oniceconnectionstatechange = @handleICEConnectionStateChange
    @peerConnection.onicecandidate = @handleICECandidate

  # This is how we determine when the WebRTC connection has ended
  handleICEConnectionStateChange: =>
    if @peerConnection.iceConnectionState == 'disconnected'
      console.log 'Client disconnected!'
      @sendAnnounceChannelMessage()

  # Handle ICE Candidate events by sending them to our remote
  handleICECandidate: (event) =>
    candidate = event.candidate
    if candidate
      candidate = candidate.toJSON()
      candidate.type = 'candidate'
      console.log 'Sending candidate to ' + @remote
      @sendSignalChannelMessage candidate
    else
      console.log 'All candidates sent'

  ### == Data Channel Functions == ###

  # This is our receiving data channel event
  handleDataChannel: (event) =>
    event.channel.onmessage = @handleDataChannelMessage

  #When receiving message
  handleDataChannelMessage: (event) =>
    console.log 'Recieved Message from master: ' + event.data
    try 
      obj = JSON.parse(event.data)
      console.log(obj)
      if @owner && !@sender
        @owner.playAnimation(obj.anim, obj.bpm)

  # This is called when the WebRTC sending data channel is offically 'open'
  handleDataChannelOpen: =>
    console.log 'Data channel created!'
    if @owner
      @owner.connected()

  # Called when the data channel has closed
  handleDataChannelClosed: =>
    console.log 'The data channel has been closed!'

  # Function to offer to start a WebRTC connection with a peer
  connect: =>
    @running = true
    @startSendingCandidates()
    @peerConnection.createOffer (sessionDescription) =>
      console.log 'Sending offer to ' + @remote
      @peerConnection.setLocalDescription sessionDescription
      @sendSignalChannelMessage sessionDescription.toJSON()

  # Function to initiate the WebRTC peerconnection and dataChannel
  initiateWebRTCState: =>
    @peerConnection = new webkitRTCPeerConnection(@servers)
    @peerConnection.ondatachannel = @handleDataChannel
    @dataChannel = @peerConnection.createDataChannel('myDataChannel')
    @dataChannel.onmessage = @handleDataChannelMessage
    @dataChannel.onopen = @handleDataChannelOpen
    @dataChannel.onclose = @handleDataChannelClosed

  constructor: (key, sender=false, owner=null) ->
    @running = false
    @servers = iceServers: [ { url: 'stun:stun.l.google.com:19302' } ]
    @owner = owner
    @sender = sender

    # Generate this browser a unique ID
    @id = Math.random().toString().replace('.', '')

    # Unique identifier for two clients to use
    @sharedKey = key

    firebaseUrl = 'https://brilliant-heat-6567.firebaseio.com/'
    @database = new Firebase(firebaseUrl)
    @announceChannel = @database.child('announce')
    @signalChannel = @database.child('messages').child(@id)
    @signalChannel.on 'child_added', @handleSignalChannelMessage
    if @sender
      @announceChannel.on 'child_added', @handleAnnounceChannelMessage

    # Send a message to the announcement channel
    @sendAnnounceChannelMessage()
module.exports = RTC
