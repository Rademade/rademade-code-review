class Synchronization::Engine::Models::Opportunity < Synchronization::Engine::Lib::Model

  class << self

    def has_own_worker?
      true
    end

    def own_worker
      Synchronization::Engine::Lib::Worker::OpportunityWorker
    end

  end
end
