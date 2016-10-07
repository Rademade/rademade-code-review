class User < ActiveRecord::Base

  has_and_belongs_to_many :projects

  scope :without_blank_name, -> { where("name <> ''") }

  paginates_per 25

  attr_accessor :plan
  attr_escaper :name, :address

  ROLES = %w[ admin admin_manager manager ].freeze

  mount_uploader :avatar, ImageUploader

  def self.get_by_email(email)
    find_by(email: email)
  end

  def password=(password)
    self.encrypted_password = encrypt_password(password) unless password.blank?
  end

  def password
    self.encrypted_password
  end

  def valid_password?(password)
    self.encrypted_password == encrypt_password(password)
  end

  def to_s
    email
  end

  def revoke_access
    self.invited = false
    self.has_access = false
    self.pass_set_token = nil
    self.encrypted_password = nil
    self.role = nil
  end

  private

  def encrypt_password(password)
    Digest::SHA1.hexdigest(password)
  end

end
