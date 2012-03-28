require 'test_helper'

class GameControllerTest < ActionController::TestCase
  test "should get details" do
    get :details
    assert_response :success
  end

  test "should get game" do
    get :game
    assert_response :success
  end

end
