# encoding: utf-8
require 'spec_helper'

describe UsersController do

	before do
		User.destroy_all
	end
	
	def mock_user(stubs={})
		@mock_user ||= mock_model(User, {:id => 123, :email => 'test+mock@wayground.ca'}.merge(stubs))
	end
	
	def set_logged_in(stubs={})
		controller.stub!(:current_user).and_return(mock_user(stubs))
	end
	
	describe "GET 'show'" do
		it "should be successful" do
			set_logged_in
			get 'show'
			response.should be_success
		end
		it "should redirect to the sign_in page if the user is not signed-in" do
			get 'show'
			response.should redirect_to(sign_in_url)
		end
	end

	describe "GET 'new'" do
		it "should be successful" do
			get 'new'
			# TODO: more descriptive check of the new user form
			response.should be_success
			# should not be a redirect:
			response.location.blank?.should be_true
		end
		it "should not show the form if the user is already signed-in" do
			set_logged_in
			get 'new'
			flash[:notice].should match /You are already signed up/i
			response.should redirect_to(account_url)
		end
	end

	describe "POST 'create'" do
		it "should not accept the user registration if the user is already signed-in" do
			set_logged_in
			post 'create'
			flash[:notice].should match /You are already signed up/i
			response.should redirect_to(account_url)
		end
		it "should fail if empty form submitted" do
			post 'create'
			# TODO: check that there are errors reported
			response.location.blank?.should be_true
		end
		it "should fail if invalid form submitted" do
			post 'create', :user => {:email => 'invalid email address',
				:password => 'invalid', :password_confirmation => 'doesn’t match'
			}
			# TODO: check that there are errors reported
			response.location.blank?.should be_true
		end
		it "should create a new user record when valid form submitted" do
			post 'create', :user => {:email => 'test+new@wayground.ca',
				:password => 'password', :password_confirmation => 'password'
			}
			flash[:notice].should match /You are now registered on this site/i
			response.should redirect_to(account_url)
		end
		it "should sign in the new user record when valid form submitted" do
			post 'create', :user => {:email => 'test+new@wayground.ca',
				:password => 'password', :password_confirmation => 'password'
			}
			(session[:user_id] > 0).should be_true
		end
	end

	describe "GET 'confirm'" do
		it "should set the user’s email_confirmation to true" do
			set_logged_in({:email_confirmed => false, :confirm_code! => true})
			get 'confirm', :confirmation_code => 'abc123'
			flash[:notice].should match /Thank-you for confirming your email address/i
			response.should redirect_to(account_url)
		end
		it "should fail if the database is not working, or some other exception occurs" do
			set_logged_in({:email_confirmed => false}) #, :confirm_code! => true})
			mock_user.stub(:confirm_code!).and_raise(:fail)
			get 'confirm', :confirmation_code => 'abc123'
			flash[:alert].should match /There was a problem/i
			response.status.should eq 500
			response.location.should eq account_url
		end
		it "should redirect to sign-in if the user is not signed-in" do
			get 'confirm', :confirmation_code => 'abc123'
			response.should redirect_to(sign_in_url)
		end
		it "should not confirm the user if the wrong code is supplied" do
			set_logged_in({:email_confirmed => false, :confirm_code! => false})
			get 'confirm', :confirmation_code => 'wrong code'
			flash[:alert].should match /Invalid confirmation code/i
			response.should redirect_to(account_url)
		end
		it "should not confirm the user if they are already confirmed" do
			set_logged_in({:email_confirmed => true})
			get 'confirm', :confirmation_code => 'abc123'
			flash[:notice].should match /Your email address was already confirmed/i
			response.should redirect_to(account_url)
		end
	end

end