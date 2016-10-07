require 'thread/pool'
require 'thread/promise'
require 'thread/process'
require 'thread/delay'

class Synchronization::Engine::Lib::Core

  class << self

    def model_name
      to_s.demodulize
    end

    def model
      model_name.constantize
    end

    def upsales_model
      "Upsales::Models::#{model_name}".constantize
    end

    def token
      Rails.application.secrets.external_api_key
    end

    def api_base_url
      Rails.application.secrets.external_api_base_url
    end

    def api_url
      [api_base_url, model_name.underscore.pluralize].join
    end

    def base_url
      [api_url, token].join('/?token=')
    end

    def benchmark(process)
      Synchronization::Engine::Lib::Logger.success Benchmark.measure { process }
    end

    def success
      'Success: 100% of data were processed'
    end

    def error(records_count, failed_records_count)
      percent = (1 - failed_records_count.to_f / records_count).round(3) * 100
      "Error: only #{percent}% of data were processed, fails count: #{failed_records_count}"
    end
  end
end
