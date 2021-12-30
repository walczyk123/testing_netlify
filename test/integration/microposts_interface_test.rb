require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def after_setup
    @user = users(:testowy)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select "div.pagination"
    assert_select "input[type=file]"
    invalid_submission
    valid_submission
    delete_post
    visit_as_different_user
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    user_without_microposts
  end

  private

  def invalid_submission
    assert_no_difference'Micropost.count' do
      post microposts_path,params: {micropost: {content:""} }
    end
    assert_select "div#error_explanation"
    assert_select "a[href=?]","/?page=2"
  end

  def valid_submission
    content = "This micropost blah blah blah"
    image = fixture_file_upload("test/fixtures/kitten.jpg","image/jpeg")
    assert_difference "Micropost.count" do
      post microposts_path, params: {micropost: {content: content, image: image}}
    end
    assert @user.microposts.first.image.attached?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
  end

  def delete_post
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end
  end

  def visit_as_different_user
    get user_path(users(:bigboy))
    assert_select "a", text: "delete", count: 0
  end

  def user_without_microposts
    other_user = users(:bigboy)
    log_in_as(other_user)
    get root_path
    assert_match "#{0} microposts",response.body
    other_user.microposts.create!(content: "micropost text")
    get root_path
    assert_match "1 micropost", response.body
  end
end
