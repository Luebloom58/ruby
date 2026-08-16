class Task < ApplicationRecord
  validates :title, presence: true, uniqueness: { case_sensitive: false, message: "is already on your list!" }
end
