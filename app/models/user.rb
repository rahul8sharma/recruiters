require 'vger/helpers/yoren_user_helper'

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  has_remote_model :yoren => {
    :attributes => [:sex, :login, :fb_user_id, :fb_email, :sid, :location_id, :name, :phone, :confirmed_at],
    :key_column => {:self => :email, :remote => :email},
    :wrapper => Vger::Yoren::User
  }
  
  include YorenUserHelper
  
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :sid
end
