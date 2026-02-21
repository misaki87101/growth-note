require "test_helper"

class FeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get feedbacks_index_url
    assert_response :success
  end

  test "should get show" do
    get feedbacks_show_url
    assert_response :success
  end

  test "should get new" do
    get feedbacks_new_url
    assert_response :success
  end

  test "should get edit" do
    get feedbacks_edit_url
    assert_response :success
  end
end
