class AddReferralDataToDailyReports < ActiveRecord::Migration[7.2]
  def change
    add_column :daily_reports, :referral_data, :json
  end
end
