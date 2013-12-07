class Question < ActiveRecord::Base
  attr_accessible :text, :poll_id

  has_many(
    :answer_choices,
    :primary_key => :id,
    :foreign_key => :question_id,
    :class_name => "AnswerChoice"
  )

  belongs_to(
    :poll,
    :primary_key => :id,
    :foreign_key => :poll_id,
    :class_name => "Poll"
  )

  validates_presence_of :poll_id

  def results
    choices = self.answer_choices.includes(:responses)
    response_count = {}
    choices.each do |choice|
      response_count[choice] = choice.responses.length
    end
    response_count
  end
end