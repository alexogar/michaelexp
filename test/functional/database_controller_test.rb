require 'test_helper'

class DatabaseControllerTest < ActionController::TestCase
  test "should get database" do
    get :database
    assert_response :success
  end

end
