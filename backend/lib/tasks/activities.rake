namespace :activities do

  desc "Starts the activites."
  task start: :environment do
    # Init the activities manager:
    am = ActivitiesManager.new

    # And start it:
    am.start
  end

end

