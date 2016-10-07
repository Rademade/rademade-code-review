app.controller 'messagesCtrl', [
  '$scope', '$rootScope', 'Message', 'Interlocutor', 'MessagesService', 'ScrollPaginationService',
  ($scope, $rootScope, Message, Interlocutor, MessagesService, ScrollPaginationService ) ->

    window.messages = {}
    query =
      limit : Message.MESSAGES_LIMIT
      startAfterId : null
      reverse : true

    params = {}

    $rootScope.moveInterlocutor = ''
    $rootScope.getMessages = (interlocutor)->
      $scope.interlocutor = interlocutor
#      $scope.isClickedInterlocutor = undefined # for mini version

      if interlocutor != undefined && !$scope.deleteting
        $scope.currentId = interlocutor.id
        if window.messages[interlocutor.id]
          $rootScope.messages = window.messages[interlocutor.id]
          return
        if $rootScope.messages and $rootScope.messages[0]
           query.startAfterId = null
        $rootScope.loadNextMessages(interlocutor)
      else
        $rootScope.messages = []
      $rootScope.popupShow('messages')


    $rootScope.loadNextMessages = (interlocutor)->

      $rootScope.messages = [] if interlocutor
      params.userId = $scope.currentUser.id
      params.interlocutorId = $scope.interlocutor.id || interlocutor.id

      ScrollPaginationService.loadNext Message, query, params, $scope, (data) ->
        $rootScope.messages = [] if  $rootScope.messages == undefined
        init = true if data.messages.length == 0
        $rootScope.messages = data.messages.concat $rootScope.messages
        Message.prepareMessages($rootScope.currentUser, $scope.interlocutor, $rootScope.messages)
        window.messages[$scope.currentId] = $rootScope.messages

        if $rootScope.messages[0]
         query.startAfterId = $rootScope.messages[0].id

        $rootScope.$emit 'messagesLoaded', init : init


    $rootScope.showMessagesPopup = (interlocutor = false)->
      Interlocutor.getInterlocutorsByUserId($scope.currentUser.id).then (interlocutors)->
        $rootScope.interlocutors = _.without interlocutors, _.findWhere interlocutors, id : interlocutor.id
        if interlocutor
          $rootScope.interlocutors.unshift(new Interlocutor(interlocutor))
          $scope.currentId = interlocutor.id
        $rootScope.popupShow('messages')
        $rootScope.getMessages $scope.interlocutors[0] if $scope.interlocutors[0]

    $scope.permitUpdateMessages =
      value : true

    $rootScope.updateMessagesStatus = ->
      return unless $scope.permitUpdateMessages.value
      new Message( userId : $rootScope.currentUser.id, interlocutorId : $scope.currentId ).update().then ->
        _.each $rootScope.messages, (message) ->
          message.new = false if message.senderId != $rootScope.currentUser.id
          true
        _.each $scope.interlocutors, (dialog) ->
          if dialog.id == $scope.currentId
            $scope.currentUser.countOfNewMessages -= dialog.countOfNewMessages
            dialog.countOfNewMessages = 0


    $rootScope.getSubMessages = (message) ->
      MessagesService.getSubMessages($rootScope.messages, message)

    $rootScope.showInterlocutorListInMiniVersionButton = ->
      $scope.isClickedInterlocutor.value = if $scope.isClickedInterlocutor.value == undefined then 'is-clicked' else undefined

]