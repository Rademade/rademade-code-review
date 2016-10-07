class Synchronization::Engine::Lib::Worker::AppointmentWorker < Synchronization::Engine::Lib::Worker

  class << self

    # All appointment types:
    # [
    #  { "name"=>"1. Bokat Möte", "id"=>17 },
    #  { "name"=>"2. Avbokat möte", "id"=>21 },
    #  { "name"=>"5. Avbok, ej fakt.", "id"=>28 },
    #  { "name"=>"7. Förstamöte - 101", "id"=>22 },
    #  { "name"=>"6. Avbokat möte- avdraget", "id"=>30 },
    #  { "name"=>"3. Kvittat möte", "id"=>27 },
    #  { "name"=>"4. Kvittat prov. möte", "id"=>31 }
    # ]

    APPOINTMENT_TYPE_IDS_FOR_BOOKED_MEETINGS = [17]

    def call(*)
      update_projects
      update_activity_types
      create_appointments
    end

    def create_appointments
      urls = Project.all.map do |project|
        project_appointments_url(project.upsales_project_id)
      end
      Synchronization::Engine::Lib::Worker.call(urls, Appointment, true)
    end

    def update_activity_types
      Synchronization::Engine::Lib::Worker.call(["https://power.upsales.com/api/v2/activitytypes/appointment?token=#{token}"], ActivityType, true)
    end

    def update_projects
      Project.all.map do |project|
        url = project_appointments_url(project.upsales_project_id)
        metadata = Synchronization::Engine::Lib::Metadata.call(url)
        appointments = Synchronization::Engine::Lib::Parallelize.load(metadata[:urls])

        booking_appointments = appointments.compact.select do |appointment|
          id = appointment['activityType']['id'] if appointment['activityType']
          APPOINTMENT_TYPE_IDS_FOR_BOOKED_MEETINGS.include?(id)
        end.count

        project.booked_meetings = booking_appointments
        project.save
      end
    end

    private

    def project_appointments_url(project_id)
      "https://power.upsales.com/api/v2/appointments/?token=#{token}&project.id=#{project_id}"
    end
  end
end
