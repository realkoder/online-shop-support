class Client < ApplicationRecord
  has_many :orders # dependent: :destroy // uncomment to add cascading deletion

  # Validations
  validates :fullname, presence: true, length: { minimum: 1, maximum: 150 }
  validates :email, presence: true, length: { minimum: 5, maximum: 150 },
    format: { with: URI::MailTo::EMAIL_REGEXP, message: "must be a valid email address" }
  validates :phone, presence: true, length: { minimum: 6, maximum: 50 }
  validates :image_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
end
