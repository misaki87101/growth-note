# frozen_string_literal: true

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :feedback, optional: true
  belongs_to :homework, optional: true
end
