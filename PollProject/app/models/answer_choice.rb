class AnswerChoice < ActiveRecord::Base
  attr_accessible :question_id, :text

  belongs_to(
    :question,
    :primary_key => :id,
    :foreign_key => :question_id,
    :class_name => "Question"
  )

  has_many(
    :responses,
    :primary_key => :id,
    :foreign_key => :answer_choice_id,
    :class_name => "Response"
  )

  validates_presence_of :question_id
end
