require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, { params: { user: { name: "", email: "invalid@invalid", password: "elo", password_confirmation: "melo" } } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.alert'
  end

  test "valid signup information with acc activation" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, { params: { user: { name: "exampleuser", email: "example@exampl.com", password: "123123123", password_confirmation: "123123123" } } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size # only one message was delivered
    user = assigns(:user)
    assert_not user.activated?
    print("only one message sent: . . . . . . . . . . . . . OK\n")
    #log before activation
    log_in_as(user)
    assert_not user.activated?
    print("login before activation: . . . . . . . . . . . . OK\n")
    #invalid activation token
    get edit_account_activation_path("invalid token",email: user.email)
    assert_not is_logged_in?
    print("Invalid activation token:. . . . . . . . . . . . OK\n")
    #valid token, wrong email
    get edit_account_activation_path(user.activation_token,email:'wrong')
    assert_not is_logged_in?
    print("invalid email, valid token:. . . . . . . . . . . OK\n")
    #valid activation token
    get edit_account_activation_path(user.activation_token,email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template'users/show'
    assert is_logged_in?
    print("valid email and token: . . . . . . . . . . . . . OK\n")

  end

end
