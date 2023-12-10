class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :directories, foreign_key: 'user_id', dependent: :destroy
  after_create :create_home_directory

  attr_writer :login

  validate :validate_username

  def validate_username
    return unless User.where(email: username).exists?

    errors.add(:username, :invalid)
  end

  def login
    @login || username || email
  end

  def create_home_directory
    directories.create(name: 'home') unless directories.exists?(name: 'home')
  end

  def find_directory_by(directory_identifier)
    directories.find_by(name: directory_identifier) || directories.find_by(id: directory_identifier)
  end

  # noinspection RubyClassMethodNamingConvention
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login))
      where(conditions.to_h).where(['lower(username) = :value OR lower(email) = :value',
                                    { value: login.downcase }]).first
    elsif conditions.key?(:username) || conditions.key?(:email)
      where(conditions.to_h).first

    end
  end
end
