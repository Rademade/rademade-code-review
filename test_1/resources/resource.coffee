angular.module('appResource', ['rails']).factory 'ChatrulezResource', [
  'RailsResource', 'ipCookie', 'config'
  (RailsResource, ipCookie, config) ->
    RailsResource.defaultParams = ->

    class ChatrulezResource extends RailsResource

    ChatrulezResource.$http = (httpConfig, resourceConfigOverrides) ->
      httpConfig.headers = 'X-Api-Key': ipCookie('API_KEY')
      return RailsResource.$http.apply @, [httpConfig, resourceConfigOverrides]

    ChatrulezResource.resourceUrl = (previous)->
      config.api_prefix + RailsResource.resourceUrl.apply @, arguments

    ChatrulezResource
]
