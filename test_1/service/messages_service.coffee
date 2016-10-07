app.service('MessagesService', [ ->

    getSubMessages : (messages, message) ->
      currentIndex =  _.indexOf messages, message
      currentIndex += 1
      result = []
      while true
        if messages.length > currentIndex  && messages[currentIndex].repeat
          result.push messages[currentIndex]
          currentIndex++
        else return result



])