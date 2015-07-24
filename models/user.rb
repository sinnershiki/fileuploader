require 'mongoid'
require 'bcrypt'
Mongoid.load!('./mongoid.yml')

class User
  include Mongoid::Document

  field :uid
  field :token
  field :name
  field :team_id
  field :team

  attr_readonly :uid, :token

  validates :uid, presence: true
  validates :token, presence: true
  validates :name, presence: true
end
