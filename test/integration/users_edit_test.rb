require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:testowy)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template "users/edit"
    patch user_path(@user), { params: { user: { name: "", email: "foo@inc", password: "foo", password_confirmation: "bar" } } }
    (assert_template "users/edit") ? @back_to_edit = "OK" : @back_to_edit = "ERR"
    (assert flash.empty?) ? @flash = "OK" : @flash = "ERR"
    (assert_select 'div#error_explanation') && (assert_select 'div.alert') ? @err_expl = "OK" : @err_expl = "ERR"
    error_explanation_diff ? @err_count = "OK" : @err_count = "ERR"
    unsuccessful_edit_test_results
  end

  # my tests : successful edit, flash message
  test"successful edit with friendly forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    name="Foo Bar"
    email="foo@bar.com"
    patch user_path(@user),{params: {user: {name:name, email: email,password:"",password_confirmation:""} }}
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name,@user.name
    assert_equal email,@user.email
    #ex1 p. 576
    log_in_as(@user)
    assert_redirected_to user_url(@user)
  end

  private

  def error_explanation_diff
    assert_no_difference 'User.count' do
      post users_path, { params: { user: { name: "", email: "invalid@invalid", password: "elo", password_confirmation: "melo" } } }
    end
  end

  def unsuccessful_edit_test_results
    puts("=== unsuccessful user edit test ===")
    print("back to edit page after unsuccessful edit: . #{@back_to_edit}\n")
    print("empty flash message: . . . . . . . . . . . . #{@flash}\n")
    print("error explanation: . . . . . . . . . . . . . #{@err_expl}\n")
    print("good number of error explanation messages: . #{@err_count}\n")
  end

  # def successful_edit_test_results
  #   puts("=== successful user edit test ===")
  #   # print("go to to user page after successful edit:. . #{@go_to_users}\n")
  #   print("flash message: . . . . . . . . . . . . . . . #{@flash2}\n")
  #   print("correctly updated user data: . . . . . . . . #{@user_data}\n")
  # end
end

# rails test test/integration/users_edit_test.rb