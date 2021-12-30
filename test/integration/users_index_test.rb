require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin = users(:testowy)
    @non_admin = users(:bigboy)
    @unactivated_user = users(:inactiveboy)
  end

  test"index including pagination shows only active users" do
    log_in_as(@admin)
    get users_path
    assert_template'users/index'
    assert_select'div.pagination', count: 2
    # this shows shows only users that were activated
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select'a[href=?]', user_path(user),text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user),text:'Delete'
      end
    end
    assert_difference "User.count", -1 do
      delete user_path(@non_admin)
    end
  end

  test "should redirect to root_url when user not activated" do
    log_in_as(@unactivated_user)
    assert_redirected_to root_url
  end

  test "should not redirect root_url when user is activated" do
    log_in_as(@non_admin)
    assert_redirected_to @non_admin
  end

end
