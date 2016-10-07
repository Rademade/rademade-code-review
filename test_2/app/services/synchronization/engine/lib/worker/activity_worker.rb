class Synchronization::Engine::Lib::Worker::ActivityWorker < Synchronization::Engine::Lib::Worker

  class << self

    DEFAULT_PARALLEL_LOADING_URLS_COUNT = 5

    def call(*)
      update_client_activities
      update_user_activities
    end

    def update_client_activities
      Client.all.map do |client|
        client_activity_url(client.upsales_client_id)
      end.each_slice(DEFAULT_PARALLEL_LOADING_URLS_COUNT).each do |urls|
        Synchronization::Engine::Lib::Worker.call(urls, Activity, true)
      end
    end

    def update_user_activities
      User.all.map do |user|
        user_activity_url(user.upsales_user_id)
      end.each_slice(DEFAULT_PARALLEL_LOADING_URLS_COUNT).each do |urls|
        Synchronization::Engine::Lib::Worker.call(urls, Activity, true)
      end
    end

    private

    def client_activity_url(client_id)
      "https://power.upsales.com/api/v2/activities/?token=#{token}&client.id=#{client_id}"
    end

    def user_activity_url(user_id)
      "https://power.upsales.com/api/v2/activities/?token=#{token}&user.id=#{user_id}"
    end

  end
end
