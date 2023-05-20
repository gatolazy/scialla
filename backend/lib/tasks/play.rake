namespace :game do

  desc "Starts the game."
  task start: :environment do
    # Init the game master:
    gm = GameMaster.new
  end

end

