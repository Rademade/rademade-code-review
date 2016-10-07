class Synchronization::Engine::Lib::Model < Synchronization::Engine::Lib::Core

  class << self

    def call
      Synchronization::Engine::Lib::Process.call(model, metadata)
    end

    def reject
      Synchronization::Engine::Lib::Process.reject(model)
    end

    def has_own_worker?
      false
    end

    def worker
      if has_own_worker?
        own_worker
      else
        Synchronization::Engine::Lib::Worker
      end
    end

    def own_worker
    end

    private

    def metadata
      Synchronization::Engine::Lib::Metadata.call(base_url)
    end
  end
end
