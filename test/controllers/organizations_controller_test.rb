require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase

  test 'should provide a list of records' do
    get :index
    assert_response :success
  end

  test 'should provide page for creating new organizations' do
    get :new
    assert_response :success
  end

end
