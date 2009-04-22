require 'test_helper'

class OptionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:options)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create option" do
    assert_difference('Option.count') do
      post :create, :option => { }
    end

    assert_redirected_to option_path(assigns(:option))
  end

  test "should show option" do
    get :show, :id => options(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => options(:one).to_param
    assert_response :success
  end

  test "should update option" do
    put :update, :id => options(:one).to_param, :option => { }
    assert_redirected_to option_path(assigns(:option))
  end

  test "should destroy option" do
    assert_difference('Option.count', -1) do
      delete :destroy, :id => options(:one).to_param
    end

    assert_redirected_to options_path
  end
end
