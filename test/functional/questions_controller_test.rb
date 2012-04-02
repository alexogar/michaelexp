# -*- encoding : utf-8 -*-
require 'test_helper'

class QuestionsControllerTest < ActionController::TestCase
  test "should get firstRound" do
    get :firstRound
    assert_response :success
  end

  test "should get lastRound" do
    get :lastRound
    assert_response :success
  end

end
