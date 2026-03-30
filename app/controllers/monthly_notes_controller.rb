# frozen_string_literal: true

class MonthlyNotesController < ApplicationController
  def create
    update_or_create
  end

  def update
    update_or_create
  end

  private

  def update_or_create
    @monthly_note = MonthlyNote.find_or_initialize_by(
      month: params[:monthly_note][:month],
      group_id: params[:monthly_note][:group_id]
    )
    if @monthly_note.update(monthly_note_params)
      redirect_to analysis_daily_reports_path(month: @monthly_note.month.strftime("%Y-%m")), notice: "メモを保存しました！"
    else
      redirect_to analysis_daily_reports_path, alert: "保存に失敗しました。"
    end
  end

  def monthly_note_params
    params.require(:monthly_note).permit(:month, :group_id, :memo)
  end
end
