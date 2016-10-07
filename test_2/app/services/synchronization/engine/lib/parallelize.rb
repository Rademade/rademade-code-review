class Synchronization::Engine::Lib::Parallelize < Synchronization::Engine::Lib::Core

  class << self

    DEFAULT_DATA_COUNT = 500
    DEFAULT_THREAD_POOL_SIZE = 25
    DEFAULT_THREAD_ERRORS_POOL_SIZE = 25
    DEFAULT_THREAD_URL_LOADING_POOL_SIZE = 10
    DEFAULT_SUB_ARRAY_SIZE = 20

    def call(data, model)
      if data.count == 0
        return
      elsif data.count < DEFAULT_DATA_COUNT
        sub_array_size = (data.count.to_f / DEFAULT_THREAD_ERRORS_POOL_SIZE).ceil
        thread_pool_size = sub_array_size
      else
        thread_pool_size = DEFAULT_THREAD_POOL_SIZE
        sub_array_size = DEFAULT_SUB_ARRAY_SIZE
      end

      pool = Thread.pool(thread_pool_size)
      failed_records = []

      data.each_slice(sub_array_size).each do |array|
        pool.process do
          array.each do |record|
            begin
              model.new(record).process_data
            rescue
              failed_records << record
            end
          end
        end
      end
      pool.shutdown

      process_failed_records(model, failed_records.compact)
    end

    def process_failed_records(model, failed_records)
      if failed_records.count > 0
        Synchronization::Engine::Lib::Logger.error error(DEFAULT_DATA_COUNT, failed_records.count)
        call(failed_records, model)
      else
        Synchronization::Engine::Lib::Logger.success(success)
      end
    end

    def load(urls)
      pool = Thread.pool(DEFAULT_THREAD_URL_LOADING_POOL_SIZE)
      promises = []

      urls.each do |url|
        pool.process do
          promise = Thread.promise
          promise << Synchronization::Engine::Lib::Response.call(url)['data']
          promises << promise
        end
      end
      pool.shutdown

      promises.map(&:~).flatten
    end

  end
end
