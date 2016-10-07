class Synchronization::Engine::Lib::Worker < Synchronization::Engine::Lib::Core

  class << self

    THREAD_POOL_SIZE = 2

    def call(urls, model, parallelize = false)
      upsales_model = "Upsales::Models::#{model.name}".constantize

      if parallelize
        pool = Thread.pool(THREAD_POOL_SIZE)
        urls.each do |url|
          pool.process do
            process(url, upsales_model)
          end
        end
        pool.shutdown

      else
        process(url, upsales_model)
      end
    end

    private

    def process(url, upsales_model)
      Synchronization::Engine::Lib::Logger.info("Load: #{url}")
      data = Synchronization::Engine::Lib::Parallelize.load([url])
      Synchronization::Engine::Lib::Parallelize.call(data, upsales_model)
    end

  end
end
