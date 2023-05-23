class Score < ApplicationRecord

  after_initialize if: :new_record? do
    self.sid = "#{self.room.id}_#{self.user.id}"
  end



  #############################################################################
  ### Relations                                                             ###
  #############################################################################

  belongs_to :room
  belongs_to :user



  #############################################################################
  ### Public instance methods                                               ###
  #############################################################################

  # A simple report.
  def report
    return {
      user: {
        id: self.user.id,
        name: self.user.display_name
      },
      score: self.score
    }
  end

end

