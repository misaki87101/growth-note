# frozen_string_literal: true

class StaffSale < ApplicationRecord
  belongs_to :daily_report
  belongs_to :user
end
