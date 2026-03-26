# frozen_string_literal: true

class BoardComment < ApplicationRecord
  belongs_to :user
  belongs_to :board
end
