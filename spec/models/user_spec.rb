# encoding: utf-8
require 'spec_helper'

describe User do
	describe "validations on create" do
		it "should fail if there is no password" do
			u = User.new
			u.email = 'test@wayground.ca'
			u.valid?.should == false
		end
		
		it "should fail if the password is less than 8 characters long" do
			u = User.new
			u.email = 'test@wayground.ca'
			u.password_confirmation = u.password = '1234567'
			u.valid?.should == false
		end
		
		it "should fail if the password is more than 63 characters long" do
			u = User.new
			u.email = 'test@wayground.ca'
			u.password_confirmation = u.password = 'a' * 64
			u.valid?.should == false
		end
		
		it "should fail if there is no password confirmation" do
			u = User.new
			u.email = 'test@wayground.ca'
			u.password = 'password'
			u.valid?.should == false
		end
		
		it "should fail if the password confirmation is blank" do
			u = User.new
			u.email = 'test@wayground.ca'
			u.password = 'password'
			u.password_confirmation = ''
			u.valid?.should == false
		end
		
		it "should fail if the password confirmation does not match" do
			u = User.new
			u.email = 'test@wayground.ca'
			u.password = 'password'
			u.password_confirmation = 'missmatch'
			u.valid?.should == false
		end
		
		it "should fail if there is no email address" do
			u = User.new
			u.password_confirmation = u.password = 'password'
			u.valid?.should == false
		end
		
		it "should fail if the email address is not a proper email address" do
			u = User.new
			u.email = 'invalid@bad-email'
			u.password_confirmation = u.password = 'password'
			u.valid?.should == false
		end
		
		it "should fail if there is already a user registered with the same email address" do
			u = User.new
			u.email = 'test+duplicate@wayground.ca'
			u.password_confirmation = u.password = 'password'
			u.save!
			u2 = User.new
			u2.email = 'test+duplicate@wayground.ca'
			u2.password_confirmation = u2.password = 'another1'
			u2.valid?.should == false
		end
		
		it "should fail if there is already a user registered with the same email address but different case" do
			u = User.new
			u.email = 'test+duplicate@wayground.ca'
			u.password_confirmation = u.password = 'password'
			u.save!
			u2 = User.new
			u2.email = 'TEST+DUPLICATE@WAYGROUND.CA'
			u2.password_confirmation = u2.password = 'another1'
			u2.valid?.should == false
		end
		
		it "should add a user record with valid parameters" do
			u = User.new
			u.email = 'test+good+parameters@wayground.ca'
			u.password_confirmation = u.password = 'password'
			u.save!
			User.find_by_email(u.email).should == u
		end
	end
	
	describe "password encryption" do
		before(:each) do
			@user = User.new
			@user.email = 'test+newuser@wayground.ca'
			@user.password_confirmation = @user.password = 'password'
			@user.save!
		end
		
		it "should save an encrypted version of a new user’s password" do
			@user.password_hash.present?.should == true
		end
		
		it "should fail to authenticate a user with a non-matching password" do
			User.authenticate(@user.email, 'wrongpassword').should == nil
		end
		
		it "should authenticate a user with a valid password" do
			User.authenticate(@user.email, 'password').should == @user
		end
	end
end