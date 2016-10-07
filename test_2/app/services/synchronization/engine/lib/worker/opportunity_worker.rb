class Synchronization::Engine::Lib::Worker::OpportunityWorker < Synchronization::Engine::Lib::Worker

  class << self

    def call(urls)
      opportunities = Synchronization::Engine::Lib::Parallelize.load(urls)
      opportunities = serialize(opportunities.compact)

      update_project_meetings(opportunities)

      Synchronization::Engine::Lib::Worker::ClientWorker.call(opportunities)
    end

    def update_project_meetings(opportunities)
      opportunities.group_by do |opportunity|
        opportunity[:upsales_project_id]
      end.each do |upsales_project_id, group|
        ordered_meetings = group.map do |project|
          project[:probability] == PROBABILITY_VALUE_TO_FILTER_ORDER_MEETINGS ? project[:ordered_meetings] : 0
        end.compact.reduce(0, :+)

        project = Project.find_by(upsales_project_id: upsales_project_id)

        if project
          project.ordered_meetings = ordered_meetings
          project.save
        end
      end
    end

    private

    def serialize(opportunities)
      opportunities.map do |opportunity|
        upsales_project_id = opportunity['project']['id'] if opportunity['project']
        upsales_client_id = opportunity['client']['id'] if opportunity['client']
        upsales_contact_id = opportunity['contact']['id'] if opportunity['contact']
        ordered_meetings = opportunity['orderRow'][0]['quantity'] if opportunity['orderRow']
        probability = opportunity['probability'] if opportunity['probability']

        {
          upsales_project_id: upsales_project_id,
          upsales_client_id: upsales_client_id,
          upsales_contact_id: upsales_contact_id,
          ordered_meetings: ordered_meetings,
          probability: probability,
          user: opportunity['user']
        }
      end
    end

  end
end
