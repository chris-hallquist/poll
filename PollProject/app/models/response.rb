class Response < ActiveRecord::Base
  attr_accessible :answer_choice_id, :user_id

  belongs_to(
    :answer_choice,
    :primary_key => :id,
    :foreign_key => :answer_choice_id,
    :class_name => "AnswerChoice"
  )

  belongs_to(
    :respondent,
    :primary_key => :id,
    :foreign_key => :user_id,
    :class_name => "User"
  )

  validates :answer_choice_id, :user_id, :presence => true
  validate :respondent_has_not_already_answered_question
  validate :respondent_is_not_answering_own_poll

  def respondent_is_not_answering_own_poll
    condition = User.joins(:authored_polls)
        .joins(:questions)
        .joins(:answer_choices)
        .where('answer_choices.user_id == ?', self.user_id).nil?
    unless condition
      errors.add(:user_id, "is answering own poll")
    end
  end

  def respondent_has_not_already_answered_question
    condition = existing_responses.empty? ||
    (existing_responses.count < 2 && existing_responses.first.id == self.id)
    unless condition
      errors.add(:user_id, "has already answered question")
    end
  end

  def existing_responses
    params = {
      :answer_choice_id => self.answer_choice_id,
      :user_id => self.user_id
    }
    Response.find_by_sql([<<-SQL, params])
        SELECT
          responses.*
        FROM
          responses
        JOIN
          answer_choices
        ON
          responses.answer_choice_id = answer_choices.id
        WHERE
          :user_id = responses.user_id AND answer_choices.question_id
        IN
          (SELECT
            question_id
          FROM
            answer_choices
          WHERE
            answer_choices.id = :answer_choice_id)
      SQL

  end
end
