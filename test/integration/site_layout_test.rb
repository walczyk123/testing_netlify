require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout_links" do
    main_page_logged_out
    main_page_logged_in
    about_page_layout
  end

#  =================== private ==============
  private

  def main_page_logged_out
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    footer_elements
  end

  def main_page_logged_in
    @user = users(:testowy)
    log_in_as(@user, remember_me: "0")
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", users_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path, count: 0
    assert_match @user.followers.count.to_s, response.body
    assert_match @user.following.count.to_s, response.body
    footer_elements
  end

  def footer_elements
    assert_select "a[href=?]", "https://github.com/walczyk123"
    assert_select "a[href=?]", about_path
  end

  def about_page_layout
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", root_path
    assert_select "a[href=?]", help_path
  end

end
