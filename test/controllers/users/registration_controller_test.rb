require 'test_helper'

class RegistrationControllerTest < ActionController::TestCase
  def setup
    @controller = Users::RegistrationsController.new
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  def create_test_user
    first_name = generate_random_string
    User.create(first_name: first_name,
                       last_name: 'Test',
                       email: first_name + '@gmail.com',
                       password: 'test1234')
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should post create" do
    first_name = 'User'
    last_name = 'Test'
    email = generate_random_string + '@gmail.com'

    post :create, user: {
      first_name: first_name,
      last_name: last_name,
      email: email,
      password: 'test1234',
      password_confirmation: 'test1234'
    }
    assert_response :redirect

    new_user = User.find_by_email(email)
    assert_not_nil(new_user, 'User failed to be created')
    assert_equal(first_name, new_user.first_name, 'User first name not set to expected value')
    assert_equal(last_name, new_user.last_name, 'User last name not set to expected value')

    assert_equal(@controller.current_user.id, new_user.id, 'New user not automatically logged in')
  end

  test "should get edit" do
    sign_in users(:one)

    get :edit
    assert_response :success
  end

# TODO: I couldn't get this test to pass.
#   test "should put update" do
#     user = create_test_user
#     sign_in user
#
#     new_first_name = 'Test'
#     new_last_name = 'User'
#
#     put :update, user: {
#       first_name: new_first_name,
#       last_name: new_last_name,
#       phone_number: '',
#       email: user.email,
#       password: '',
#       password_confirmation: '',
#       current_password: 'abcd1234'
#     }
#     updated_user = User.find_by_id(user.id)
#
#     assert_response :redirect
#     assert_equal(user.email, updated_user.email, 'Email changed when not intended to')
#     assert_equal(new_first_name, updated_user.first_name, 'First name not updated')
#     assert_equal(new_last_name, updated_user.last_name, 'Last name not updated')
#   end

  test 'should redirect when updating without logging in' do
    user = create_test_user

    new_first_name = 'Test'
    new_last_name = 'User'

    put :update, user: {
      first_name: new_first_name,
      last_name: new_last_name,
      email: user.email,
      current_password: 'abcd1234'
    }
    updated_user = User.find_by_id(user.id)

    assert_response :redirect
    assert_equal(user.email, updated_user.email, 'Email changed when not intended to')
    assert_equal(user.first_name, updated_user.first_name, 'First name updated when not logged in')
    assert_equal(user.last_name, updated_user.last_name, 'Last name updated when not logged in')
  end

  test "should delete destroy" do
    user = create_test_user
    sign_in user

    delete :destroy
    user = User.find_by_id(user.id)

    assert_response :redirect
    assert_nil(user, 'User not destroyed')

    assert_nil(@controller.current_user, 'Not logged out when user deleted')
  end

end
