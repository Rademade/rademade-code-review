app.factory 'Client', ['config', 'CookiesService', (config, CookiesService) ->
  client = new Faye.Client("#{config.ws_server}")
  client.disable('websocket')
  client
]