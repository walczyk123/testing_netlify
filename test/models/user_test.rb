require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "ziomek12", email: "ziom12@ziom.com", password: "1qaz233", password_confirmation: "1qaz233")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    #list of emails that are good
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp allice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      #showing which email is wrong at this moment
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    #list of emails that are good
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@gar+baz.com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      #showing which email is wrong at this moment
      assert @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPlE.Com"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? false for user with nil digest" do
    assert_not @user.authenticated?(:remember, "")
  end

  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    testowy = users(:testowy)
    smollboy = users(:smollboy)
    assert_not testowy.following?(smollboy)

    testowy.follow(smollboy)
    assert testowy.following?(smollboy)
    assert smollboy.followers.include?(testowy)

    testowy.unfollow(smollboy)
    assert_not testowy.following?(smollboy)
  end

  test "feed should have the right posts" do
    testowy = users(:testowy)
    smollboy = users(:smollboy)
    bigboy = users(:bigboy)
    bigboy.microposts.each do |post_following|
      assert testowy.feed.include?(post_following)
    end
    testowy.microposts.each do |post_self|
      assert testowy.feed.include?(post_self)
    end
    smollboy.microposts.each do |post_unfollowed|
      assert_not testowy.feed.include?(post_unfollowed)
    end
  end




end
