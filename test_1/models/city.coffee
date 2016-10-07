app.factory 'City', ['ChatrulezResource', (ChatrulezResource) ->

  class City extends ChatrulezResource
    @configure url : '/cities', name : 'city'

]