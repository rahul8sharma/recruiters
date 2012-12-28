require 'vger/helpers/yoren_user_helper'
require 'vger/spartan/vanguard/recruiter'
require 'vger/yoren/user'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  has_remote_model :leonidas => {
    :attributes => [],
    :key_column => {:self => :sid, :remote => :user_id},
    :wrapper => Vger::Spartan::Vanguard::Recruiter
  },:yoren => {
    :attributes => [:sex, :login, :fb_user_id, :fb_email, :sid, :location_id, :name, :phone, :confirmed_at, :reset_password_token],
    :key_column => {:self => :email, :remote => :email},
    :wrapper => Vger::Yoren::User
  }
  
  include YorenUserHelper
  
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :sid, :name, :phone
  #attr_accessor :name, :phone
end
