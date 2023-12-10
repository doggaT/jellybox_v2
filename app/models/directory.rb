class Directory < ActiveRecord::Base
  belongs_to :user, foreign_key: 'user_id'
  belongs_to :parent, class_name: 'Directory', optional: true
  has_many :subdirectories, class_name: 'Directory', foreign_key: 'parent_id', dependent: :destroy
  has_many_attached :files, dependent: :destroy

  validates :name, presence: true

end
