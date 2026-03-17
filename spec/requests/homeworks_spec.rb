require 'rails_helper'

RSpec.describe "Homeworks", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/homeworks/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/homeworks/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/homeworks/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/homeworks/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
