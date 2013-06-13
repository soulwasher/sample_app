# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe User do
	before { @user = User.new(name: "Example User", email: "user@example.com",
								password: "foobar", password_confirmation: "foobar")}
	subject { @user }
	it { should respond_to(:name) }
	it { should respond_to(:email) }
	it { should respond_to(:password_digest) }
	it { should respond_to(:password) }
	it { should respond_to(:password_confirmation) }
	it { should respond_to(:remember_token) }
	it { should respond_to(:authenticate) }
	
	it { should be_valid}

	#user name validations	
	describe "when name is not present" do
		before { @user.name = "" }
		it { should_not be_valid }
	end
	
	describe "when name is too long" do
		before { @user.name = "a" * 51 }
		it { should_not be_valid }
	end
	
	#password validations
	describe "when password is not present" do
		before { @user.password = @user.password_confirmation = "" }
		it { should_not be_valid }
	end
	
	describe "when password and password_confirmation do not match" do
		before { @user.password_confirmation = "mismatch" }
		it { should_not be_valid }
	end
	
	describe "when password_confirmation is nil" do
		before { @user.password_confirmation = nil }
		it { should_not be_valid }
	end
	
	describe "when password is too short" do
		before { @user.password = @user.password_confirmation = "12345" }
		it { should_not be_valid }
	end
	
	#email validations
	describe "when email address is already taken" do
		before do
			user_with_the_same_email = @user.dup
			user_with_the_same_email.email = @user.email.upcase
			user_with_the_same_email.save
		end
		
		it { should_not be_valid }
	end

	describe "when email is invalid" do
		it "should be invalid" do
			invalid_emails = ["emails", "email_at_domain.com", "email.com", "email@domain", "email@domain."]
			invalid_emails.each do |invalid_email|
				@user.email = invalid_email
				@user.should_not be_valid
			end
			
			valid_emails = ["email@domain.com", "email.email@domain.com", "email@do.main.com"]
			valid_emails.each do |valid_email|
				@user.email = valid_email
				@user.should be_valid
			end
		end
	end
	
	describe "should be saved in downcase" do
		let(:mixed_case_email) { "MixEd@CasE.EmaiL" }
		
		it "should be saved in lower case" do
			@user.email = mixed_case_email
			@user.save
			@user.reload.email.should == mixed_case_email.downcase
		end
	end
	
	
	
	#authentication validation
	describe "return value of authenticate method" do
		before { @user.save }
		let(:found_user) { User.find_by_email(@user.email) }
		
		describe "with valid password" do
			it { should == found_user.authenticate(@user.password) }
		end
		
		describe "with invalid password" do
			let(:user_for_invalid_password) { found_user.authenticate("invalid") }
			it { should_not == user_for_invalid_password }
			specify { user_for_invalid_password.should be_false }
		end
	end
	
	#make sure the sign_in token is saved
	describe "remember token" do
		before { @user.save }
		its(:remember_token) { should_not be_blank }
	end
end
