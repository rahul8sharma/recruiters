class UsersController < ApplicationController
	layout "users"
	def login
	  redirect_to after_sign_in_path_for if current_user
		if request.post?
		  begin
			  sign_in(params[:user])
			rescue Faraday::Unauthorized => e
			  flash[:error] = e.response[:body][:data][:error]
			end
		else
		end
	end
	
	def logout
		sign_out()
	end

	def forgot_password
	  
	end
	
	def send_reset_password
	  @user = Vger::Resources::User.send_reset_password_instructions(params[:user])
	  if @user.error_messages && @user.error_messages.empty?
	    flash[:notice] = "Instructions to reset your password have been sent to #{params[:user][:email]}"
	    redirect_to login_path
	  else
	    flash[:error] = @user.error_messages.join("<br/>").html_safe
	    redirect_to forgot_password_path
	  end
	end
	
	def reset_password
	end

	def update_password
	  @user = Vger::Resources::User.reset_password_by_token(params[:user])
    if @user.error_messages && @user.error_messages.empty?
      flash[:notice] = "Password was reset successfully!"
	    sign_in(:auth_token => @user.authentication_token)
    else
      flash[:error] = @user.error_messages.join("<br/>").html_safe
      redirect_to reset_password_path(:reset_password_token => params[:user][:reset_password_token])
    end
	end
end
