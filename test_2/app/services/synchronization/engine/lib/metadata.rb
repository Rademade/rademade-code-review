class Synchronization::Engine::Lib::Metadata

  class << self

    RECORDS_PER_REQUEST = 500

    def call(base_url, only_active_pages = false)
      ping_url = url(base_url, only_active_pages)
      response = Synchronization::Engine::Lib::Response.call(ping_url)
      metadata = response['metadata']

      if metadata['error'].present?
        Synchronization::Engine::Lib::Logger.error(error(metadata))
        metadata
      else
        Synchronization::Engine::Lib::Logger.success("metadata: #{metadata}")
        count = (metadata['total'].to_f / RECORDS_PER_REQUEST).ceil

        {
          :limit => RECORDS_PER_REQUEST,
          :total => metadata['total'],
          :urls => urls(base_url, count, only_active_pages,RECORDS_PER_REQUEST)
        }
      end
    end

    private

    def urls(base_url, count, only_active_pages, limit)
      (1..count).map do |n|
        [url(base_url, only_active_pages), "limit=#{limit}", "offset=#{(n - 1) * limit}"].join('&')
      end
    end

    def url(url, only_active)
      only_active ? [url, '&active=1'].join : url
    end

    private

    def error(metadata)
      "Error: #{metadata['error']} by url: #{response['url']}"
    end
  end
end
