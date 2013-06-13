class SessionsController < ApplicationController
	def new
	end

	def create
		user = User.find_by_email(params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			sign_in (user)
			redirect_to user
		else
			if user == nil
				flash.now[:error] = 'Sign in failed! Email not found, please correct the email or sign up'
			else 
				flash.now[:error] = 'Sign in failed! Wrong password! Check your language and Caps Lock and try again'
			end
			render 'new'
		end
	end

	def destroy
		sign_out
		redirect_to '/'
	end
end
