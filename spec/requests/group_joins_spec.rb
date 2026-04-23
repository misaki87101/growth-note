# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "GroupJoins", type: :request do
  describe "GET /new" do
    it "returns http success" do
      get "/group_joins/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/group_joins/create"
      expect(response).to have_http_status(:success)
    end
  end
end
