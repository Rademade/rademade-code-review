app.factory 'Message', [
  'ChatrulezResource', 'ParserService'
  (ChatrulezResource, ParserService) ->

    class Message extends ChatrulezResource
      @configure url : '/users/{{userId}}/interlocutors/{{interlocutorId}}/messages', rootWrapping: false

      @MESSAGES_LIMIT = 50

      @prepareMessages = (user, interlocutor, messages)->
          _setRepeatFlag(messages)
          _setUser(messages, user, interlocutor)
          _prepareText(messages)

      _setRepeatFlag = (messages)->
          last = {}
          _.each messages, (message)->
            message.repeat = true if message.senderId == last.senderId
            message.new = true if message.new == 1
            last = message

      _setUser = (messages, user, interlocutor)->
         _.each messages, (message)->
           message.user = if message.senderId == user.id then user else interlocutor

      _prepareText = (messages)->
         _.each messages, (message)->
           message.content = ParserService.replaceMessageIndents(message.content)

      checkMessageExists : (messages)->
        @repeat = true if messages[messages.length - 1].senderId == @senderId

]