class Synchronization::Engine::Lib::Process < Synchronization::Engine::Lib::Core

  class << self

    DEFAULT_THREAD_POOL_SIZE = 25

    def call(model, metadata)
      return if metadata[:total] == 0
      sync_model = "Synchronization::Engine::Models::#{model.name}".constantize

      if sync_model.has_own_worker?
        sync_model.worker.call(metadata[:urls])
      else
        sync_model.worker.call(metadata[:urls], model, true)
        show_loading_info(model, metadata)
      end
    end

    def reject(model)
      if model.count.zero?
        Synchronization::Engine::Lib::Logger.success("Rejected #{model.name}")
        return
      else
        if model.count < DEFAULT_THREAD_POOL_SIZE
          pool_size = model.count
        else
          pool_size = DEFAULT_THREAD_POOL_SIZE / 2
        end
        Synchronization::Engine::Lib::Logger.warning("Rejecting #{model.name}: #{model.count}")
      end

      pool = Thread.pool(pool_size)
      delay = Thread.delay { model.all }

      (~delay).each do |record|
        pool.process { record.destroy }
      end
      pool.shutdown

      reject(model)
    end

    private

    def show_loading_info(model, metadata)
      Synchronization::Engine::Lib::Logger.warning("#{model.name} current count: #{model.count}")

      if metadata[:total] > 0
        percent = (model.count.to_f / metadata[:total]).round(3) * 100

        if percent < 100
          Synchronization::Engine::Lib::Logger.error error(percent)
        else
          Synchronization::Engine::Lib::Logger.success(success)
        end
      end
    end

    def success
      'Success: 100% of data were synchronized'
    end

    def error(percent)
      "Error: only #{percent}% of data were synchronized"
    end
  end
end
