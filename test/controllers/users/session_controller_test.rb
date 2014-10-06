require 'test_helper'

class SessionControllerTest < ActionController::TestCase
  def setup
    @controller = Devise::SessionsController.new
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should redirect when user is already logged in" do
    user = users(:one)
    sign_in user

    get :new
    assert_response :redirect
  end

  test "should post create" do
    user = users(:one)
    post :create, user: {
      email: user.email,
      password: 'abcd1234'
    }

    assert_response :redirect
    assert_not_nil(@controller.current_user, 'User not logged in')
  end

  test "should not allow users to log in with wrong password" do
    user = users(:one)
    post :create, user: {
      email: user.email,
      password: 'abcd12345'
    }

    assert_response :success
    assert_nil(@controller.current_user, 'User logged in with wrong password')
  end

  test "should delete destroy" do
    user = users(:one)
    sign_in user

    delete :destroy
    assert_response :redirect

    assert_nil(@controller.current_user, 'User logged out failed')
  end

  test "should redirect on delete when not logged in" do
    delete :destroy
    assert_response :redirect

    assert_nil(@controller.current_user, 'User logged out failed')
  end

end
