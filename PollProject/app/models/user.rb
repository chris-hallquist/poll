class User < ActiveRecord::Base
  attr_accessible :user_name

  validates_uniqueness_of :user_name
  validates_presence_of :user_name

  has_many(
    :authored_polls,
    :primary_key => :id,
    :foreign_key => :author_id,
    :class_name => "Poll"
  )

  has_many(
    :responses,
    :primary_key => :id,
    :foreign_key => :user_id,
    :class_name => "Response"
  )

  def completed_polls
    #self.responses.joins(:answer_choice).joins(:question).joins(:poll)
    Poll.find_by_sql([<<-SQL, {:user_id => self.id }])
      SELECT
        polls.*, COUNT(*) AS poll_question_count,
        (SELECT
           COUNT(*)
         FROM
           responses
         JOIN
           answer_choices
         ON
           responses.answer_choice_id = answer_choices.id
         JOIN
           questions
         ON
           questions.id = answer_choices.question_id
         JOIN
           polls
         ON
           polls.id = questions.poll_id
         WHERE
           responses.user_id = :user_id
         GROUP BY
           polls.id
        ) AS poll_response_count
      FROM
        polls
      WHERE
        poll_question_count = poll_response_count
      GROUP BY
        polls.id

    SQL
  end
end
