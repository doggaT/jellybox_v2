class FileNode < ActiveRecord::Base
  belongs_to :directory, foreign_key: 'directory_id'
  has_one :user, class_name: 'User', through: :directory
  has_one_attached :file_node, dependent: :destroy
  validates :file_node, presence: true

  after_create_commit :attach_file_to_storage

  private

  def attach_file_to_storage
    return unless file_path.attached?

    file_path.each do |file|
      file_node.attach(file.blob)
    end
  end
end
