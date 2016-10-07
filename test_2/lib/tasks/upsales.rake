namespace :upsales do

  desc 'Synchronize all data from upsales API'
  task call: :environment do
    Synchronization::Upsales.call
  end

  desc 'Destroy all data from upsales API'
  task reject: :environment do
    Synchronization::Upsales.destroy
  end

  desc 'Reload all data from upsales API'
  task reload: :environment do
    Synchronization::Upsales.reject
    Synchronization::Upsales.call
  end

  desc 'Create test user'
  task user: :environment do
    User.create(email: 'mp@rademade.com', password: 'rademade', admin: true, role: 'admin')
  end

end
