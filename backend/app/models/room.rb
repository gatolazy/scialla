class Room < ApplicationRecord

  #############################################################################
  ### Relations                                                             ###
  #############################################################################

  belongs_to :activity
  has_many :scores
  has_many :users, through: :scores

end

