app.factory 'Country', ['ChatrulezResource', (ChatrulezResource) ->

  class Country extends ChatrulezResource
    @configure url : '/countries', name : 'country'

]