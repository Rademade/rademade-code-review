class Synchronization::Upsales

  class << self

    MODELS_REJECT_EXEPTION = ['Opportunity']
    MODELS_PATH = Dir.pwd + '/app/services/synchronization/engine/models/'
    MODELS_PREFIX = 'Synchronization::Engine::Models'
    MODEL_NAMES_WITH_STRICT_ORDER = [
      'User', 'Project', 'Opportunity',
    ]

    def call
      models.each(&:call)
    end

    def reject
      models.reject do |model|
        MODELS_REJECT_EXEPTION.include? model.name.demodulize
      end.reverse.each(&:reject)
    end

    private


    def models
      MODEL_NAMES_WITH_STRICT_ORDER.map do |name|
        [MODELS_PREFIX, name].join('::').constantize
      end
    end

  end
end
