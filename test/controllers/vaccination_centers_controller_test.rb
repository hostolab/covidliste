require "test_helper"

class VaccinationCentersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get vaccination_centers_new_url
    assert_response :success
  end

  test "should get create" do
    get vaccination_centers_create_url
    assert_response :success
  end
end
