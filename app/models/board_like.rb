# frozen_string_literal: true

class BoardLike < ApplicationRecord
  belongs_to :user
  belongs_to :board
end
