app.controller 'ChatCtrl',
  ['$scope', '$rootScope', 'Message', 'Client', 'UserState', 'ScrollDownElement', 'Interlocutor', 'ParserService',
  ($scope, $rootScope, Message, Client, UserState, ScrollDownElement,
   Interlocutor, ParserService) ->

    MOBILE_WIDTH = 750
    ID_ELEMENT_WITH_SCROLL = 'with-scroll'
    $rootScope.messages = []

    $scope.sendMessage = ->
     if $scope.message and $rootScope.interlocutors.length != 0
#       $scope.message = ParserService.replaceMessageIndents($scope.message)
       $scope.message =
       message = new Message(
         userId : $rootScope.currentUser.id,
         interlocutorId : $scope.currentId,
         text : $scope.message,
         content : $scope.message
       )
       message.senderId = $rootScope.currentUser.id
       message.new = true
       message.save().then (m)->
         m.content = ParserService.replaceMessageIndents(m.content)
       message.repeat = true if _showMessageInARow()
       message.date = new Date()
       _prepareMessages(message)
       _moveInterlocutor($scope.currentId)
       $scope.message = ''

    UserState.currentUser ->
      return  unless $rootScope.currentUser
      Client.subscribe "/messenger/#{$rootScope.currentUser.fayeChannel}", (data) ->
        message = data.message
        _handleAnyMessage(message) if message
        _addNewMessageToList(message) if _isMessageFromCurrentInterlocutor(message)
        if _shouldUpdateMessagesStatus(data)
          _readInterlocutorMessages(data.interlocutorId)
        $rootScope.$apply()

    _prepareMessages = (message) ->
       $rootScope.moveInterlocutor = $scope.currentId
       message.user = if message.senderId == $rootScope.currentUser.id then user else _.findWhere $rootScope.interlocutors, id : message.senderId
       message.content = ParserService.replaceMessageIndents(message.content)
       $rootScope.messages.push  message

    _moveInterlocutor = (id) ->
      lastInterlocutor = _.findWhere $rootScope.interlocutors, id : id
      return unless lastInterlocutor
      $rootScope.interlocutors = _.without($rootScope.interlocutors, lastInterlocutor)
      $rootScope.interlocutors.unshift lastInterlocutor

    _getLastInterlocutor = (senderId) -> _.findWhere $rootScope.interlocutors, id : senderId

    _showMessageInARow = ->
      $rootScope.messages.length != 0 and $rootScope.currentUser.id == $rootScope.messages[$rootScope.messages.length - 1].senderId

    _createNewInterlocutor = ->
      Interlocutor.getInterlocutorsByUserId($rootScope.currentUser.id).then (interlocutors) ->
        $rootScope.interlocutors = interlocutors
        lastInterlocutor = _getLastInterlocutor(data.message.senderId)
        _moveInterlocutor(data.message.senderId)
        $rootScope.getMessages(lastInterlocutor)


    _handleAnyMessage = (message) ->
      lastInterlocutor = _getLastInterlocutor(message.senderId)
      if lastInterlocutor
        _moveInterlocutor(message.senderId)
        lastInterlocutor.countOfNewMessages++
      else
        _createNewInterlocutor()

    _isMessageFromCurrentInterlocutor = (message) ->
      message && message.senderId == $scope.currentId

    _addNewMessageToList = (message) ->
      message = new Message(message)
      message.checkMessageExists($rootScope.messages)
      _prepareMessages(message)
      ScrollDownElement.byId(ID_ELEMENT_WITH_SCROLL)

    _shouldUpdateMessagesStatus = (data) -> data.interlocutorId

    _readInterlocutorMessages = (interlocutorId) ->
      for message in  $rootScope.messages
         if message.receiverId * 1 == interlocutorId * 1
            message.new = false

]






