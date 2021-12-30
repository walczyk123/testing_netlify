require "test_helper"

class UserControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:testowy)
    @other_user = users(:smollboy)
  end

  test "should redirect following when not logged in" do
    get following_user_path(@user)
    assert_redirected_to login_url
  end

  test "should redirect followers when not logged in" do
    get followers_user_path(@user)
    assert_redirected_to login_url
  end
end
