app.factory 'Interlocutor', ['ChatrulezResource', 'railsSerializer', (ChatrulezResource, railsSerializer) ->

  class Interlocutor extends ChatrulezResource
    @configure
      url : '/users/{{userId}}/interlocutors/{{id}}'
      name : 'interlocutors'
      serializer: railsSerializer ->
        _deserializeObjectCopy = @deserializeObject
        @deserializeObject = (result, data) =>
          data.formattedId = "id#{data.id}"
          _deserializeObjectCopy.apply(this, [result, data])

    @getInterlocutorsByUserId = (userId) -> @get(userId : userId)

]