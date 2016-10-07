require 'rest-client'

class Synchronization::Engine::Lib::Response

  class << self

    def call(url)
      JSON.parse RestClient.get(url)
    rescue => e
      return { 'error' => e, 'url' => url }
    end

  end
end
