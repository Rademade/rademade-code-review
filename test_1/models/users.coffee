app.factory 'User', [
  'ChatrulezResource', 'DateService', 'Friend', 'Subscriber', 'railsSerializer',
  (ChatrulezResource, DateService, Friend, Subscriber, railsSerializer ) ->

    class User extends ChatrulezResource

      @configure
        url : '/users/{{id}}'
        name : 'user'
        serializer: railsSerializer ->
          _deserializeObjectCopy = @deserializeObject
          @deserializeObject = (result, data) =>
            data.formattedId = "id#{data.id}"
            _deserializeObjectCopy.apply(this, [result, data])

      @userById = (id, callback)->
        @get(id).then (user)->
          callback(user)



      compare : (user)-> @id + '' == user.id + ''

      findUserInSubscribers : (friendId) ->
        Subscriber.get(friendId : @id, userId : friendId)

      sendFriendsRequest: (friendId)->
        new Subscriber(friendId : @id, userId : friendId).create()

      deleteFromFriends: (friendId)->
        new Subscriber(friendId : @id, userId : friendId).delete()

]