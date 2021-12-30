class User < ApplicationRecord
  has_many :microposts, dependent: :destroy

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save :downcase_email
  before_create :create_activation_digest
  has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :pasive_relationships, class_name: "Relationship", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :pasive_relationships, source: :follower

  validates(:name, presence: true, length: { maximum: 50 })
  #validation of email, it has to be input, with max length 255, fulfill regex format, be unique and no case sEnSiTiVe
  # since we added callback before_save, which put all letters downcase, we also use uniqueness:true again
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates(:email, presence: true, length: { maximum: 255, format: { with: /VALID_EMAIL_REGEX/ } }, uniqueness: true)
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end

  #Remember user in DB for persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # True if token matches digest
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  # def feed
  #   following_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
  #   Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id",user_id:id)
  #   # Micropost.where("user_id IN (?) = ?", following_ids,id) #ex1 p.885
  #   # Micropost.where("user_id = ?", following_ids,id)  #ex2 p. 885
  #   #Micropost.all #ex3 p. 855
  # end

  def feed
    part_of_feed = "relationships.follower_id = :id or microposts.user_id = :id"
    Micropost.joins(user: :followers).where(part_of_feed, { id: id })
  end

  #==================== following users =====================================
  def follow(other_user)
    following << other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  #==================== activate  and password reset ========================
  def activate
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  #=================================== private ==============================

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

end

