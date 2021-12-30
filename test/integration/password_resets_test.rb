require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def after_setup
    ActionMailer::Base.deliveries.clear
    @user = users(:testowy)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template "password_resets/new"
    assert_select "input[name=?]", "password_reset[email]"
    is_email_invalid?
    is_email_valid?
    user=password_reset_form
    wrong_email_test(user)
    inactive_user_test(user)
    user.toggle!(:activated)
    good_email_wrong_token_test(user)
    good_email_good_token_test(user)
    passwords_mismatch_test(user)
    password_empty_test(user)
    valid_information_test(user)
    token_expire_after_reset?(user)

  end

  test"expired token" do
    get new_password_reset_path
    post password_resets_path, params: {password_reset: {email:@user.email } }
    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at,3.hours.ago)
    patch password_reset_path(@user.reset_token),
          params: {email:@user.email,user: {password:"foobar",password_confirmation:"foobar"} }
    assert_response :redirect
    follow_redirect!
    assert_match (/expired/i), response.body
  end


  private

  def is_email_invalid?
    post password_resets_path, params: {password_reset: {email:""} }
    assert_not flash.empty?
    assert_template"password_resets/new"
  end

  def is_email_valid?
    post password_resets_path, params: {password_reset: {email:@user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url
  end

  def password_reset_form
    assigns(:user)
  end

  def wrong_email_test(user)
    get edit_password_reset_path(user.reset_token,email:"")
    assert_redirected_to root_url
  end

  def inactive_user_test(user)
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token,email: user.email)
    assert_redirected_to root_url
  end

  def good_email_wrong_token_test(user)
    get edit_password_reset_path('wrong token',email: user.email)
    assert_redirected_to root_url
  end

  def good_email_good_token_test(user)
    get edit_password_reset_path(user.reset_token,email: user.email)
    assert_template'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email
  end

  def passwords_mismatch_test(user)
    patch password_reset_path(user.reset_token),params: {email: user.email,user: {password:"foobaz",password_confirmation:"barquux"} }
    assert_select'div#error_explanation'
  end

  def password_empty_test(user)
    patch password_reset_path(user.reset_token),params: {email: user.email,user: {password:"",password_confirmation:""} }
    assert_select'div#error_explanation'
  end

  def valid_information_test(user)
    patch password_reset_path(user.reset_token),params: {email: user.email, user: {password:"foobaz",password_confirmation:"foobaz"} }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  def token_expire_after_reset?(user)
    user.reload
    assert_nil user.reset_digest
  end
end


