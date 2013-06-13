require 'spec_helper'

describe "User pages" do
	subject { page }
	describe "signup page" do
		before { visit signup_path }
		it { should have_selector('h1',    text: 'Sign up') }
		it { should have_selector('title', text: full_title('Sign up')) }
	end


	describe "profile page" do
		let(:user) { FactoryGirl.create(:user) }
		before { visit user_path(user) }
		
		it { should have_selector('h1',    text: user.name) }
		it { should have_selector('title', text: user.name) }
	end
	
	describe "signup" do
		before { visit signup_path }
		let(:submit) { "Create my account" }
		
		describe "with invalid information" do
			it "should not create a user" do
				expect { click_button submit }.not_to change(User, :count)
			end
		end

		describe "with valid information" do
			before do
				fill_in "Name",         with: "Example User"
				fill_in "Email",        with: "user@example.com"
				fill_in "Password",     with: "foobar"
				fill_in "Confirmation", with: "foobar"
			end

			it "should create a user" do
				expect { click_button submit }.to change(User, :count).by(1)
				page { should have_selector('h1',    text: user.name) }
				page { should have_selector('title', text: user.name) }
				page { should have_selector('div.alert.alert-success', text: 'Welcome') }
				page { should have_link('Sign out') }
			end
		end
		
		#signup error messages
		describe "with blank name, invalid email and no password" do
			before do
				fill_in "Name",			with: ""
				fill_in "Email",		with: "invalid"
			end
			
			it "should display an error message" do
				click_button submit 
				should have_selector('li', text: "Name can't be blank")
				should have_selector('li', text: "Email is invalid")
				should have_selector('li', text: "Password can't be blank")
				should have_selector('li', text: "Password is too short (minimum is 6 characters)")
				should have_selector('li', text: "Password confirmation can't be blank")
			end
		end
		
		describe "with normal name, empty email, short password and password mismatch" do
			before do
				fill_in "Name",			with: "Good Name"
				fill_in "Email",		with: ""
				fill_in "Password",     with: "12345"
				fill_in "Confirmation", with: "54321"
			end
			
			it "should display an error message" do
				click_button submit 
				should have_selector('li', text: "Email is invalid")
				should have_selector('li', text: "Email can't be blank")
				should have_selector('li', text: "Password is too short (minimum is 6 characters)")
				should have_selector('li', text: "Password doesn't match confirmation")
			end
		end
	end
end
