class Synchronization::Engine::Lib::Worker::ClientWorker < Synchronization::Engine::Lib::Worker

  class << self

    def call(data)
      create_or_update_clients(data)
      create_or_update_contacts(data)

      data.group_by do |hash|
        hash[:upsales_client_id]
      end.each do |upsales_client_id, data|
        client = Client.find_by(upsales_client_id: upsales_client_id)

        if client
          update_client_projects(client, data)
          update_client_users(client, data)
          update_client_categories(client, data)
          update_client_contacts(client, data)
        end
      end
    end

    private

    def create_or_update_clients(data)
      urls = data.map do |node|
        node[:upsales_client_id]
      end.uniq.map do |id|
        client_url(id)
      end

      process(urls, Upsales::Models::Client)
    end

    def create_or_update_contacts(data)
      urls = data.map do |node|
        node[:upsales_contact_id]
      end.uniq.map do |id|
        contact_url(id)
      end

      process(urls, Upsales::Models::Contact)
    end

    def update_client_projects(client, data)
      ids = data.map { |node| node[:upsales_project_id] }
      client.projects = Project.where(upsales_project_id: ids)
      client.save
    end

    def update_client_users(client, data)
      ids = data.map { |node| node[:user]['id'] }
      client.users = User.where(upsales_user_id: ids)
      client.save
    end

    def update_client_categories(client, data)
      ids = data.compact.map do |node|
        node[:user]
      end.compact.map do |user|
        user['role']
      end.compact.map do |role|
        role['id']
      end.uniq

      client.client_categories = ClientCategory.where(upsales_client_category_id: ids)
      client.save
    end

    def update_client_contacts(client, data)
      ids = data.map do |node|
        node[:upsales_contact_id]
      end.uniq

      client.contacts = Contact.where(upsales_contact_id: ids)
    end

    def process(urls, model)
      data = Synchronization::Engine::Lib::Parallelize.load(urls).compact
      Synchronization::Engine::Lib::Parallelize.call(data, model)
    end

    def client_url(client_id)
      "https://power.upsales.com/api/v2/accounts/?token=#{token}&id=#{client_id}"
    end

    def contact_url(contact_id)
      "https://power.upsales.com/api/v2/contacts/?token=#{token}&id=#{contact_id}"
    end

  end
end
