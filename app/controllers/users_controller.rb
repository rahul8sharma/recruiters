class UsersController < ApplicationController
	layout "users"
	def login
	  redirect_to root_path if current_user
		if request.post?
		  begin
			  sign_in(params[:user])
			rescue Faraday::Unauthorized => e
			  flash[:notice] = e.response[:body][:data][:error]
			end
		else
		end
	end
	
	def logout
		sign_out()
	end

	def forgot_password
	end

	def reset_password
	end
end
