# encoding: utf-8
require 'factory_girl'

FactoryGirl.define do

  # GLOBAL SEQUENCES
  # These are global sequences that can be used across factories to avoid name collisions.
  # For example, to get a unique email address in a given factory, call:
  #   email_attribute_name { generate(:email) }

  sequence :email do |n|
    "email#{n}-#{rand(100)}@factory.tld"
  end
  sequence :uid do |n|
    n
  end

  # FACTORIES

  factory :test_model do
    test_attribute 'value'
  end

  factory :authentication do
    user
    provider        'twitter'
    uid
    sequence(:name) {|n| "Auth User#{n}"}
  end

  # note that this factory will require being called with a value for either :item or :area, or it will fail
  factory :authority do
    user
    factory :owner_authority do
      is_owner true
      can_create true
      can_view true
      can_update true
      can_delete true
      can_invite true
      can_permit true
      can_approve true
    end
  end

  factory :document do
    user
    sequence(:filename) {|n| "factory_document_#{n}.txt"}
    #size {4} # should be auto-set by Document model, based on self.data
    content_type 'text/plain'
    description  'This is a factory-generated Document.'
    data         'data'
  end

  factory :event do
    sequence(:start_at) {|n| n.days.from_now.to_datetime.to_s(:db)}
    sequence(:title)    {|n| "Factory Event #{n}"}
    editor
    factory :event_future do
      # new events are in the future by default
    end
    factory :event_past do
      sequence(:start_at) {|n| n.days.ago.to_datetime.to_s(:db)}
    end
  end

  factory :external_link do
    sequence(:title) {|n| "Factory Link #{n}"}
    sequence(:url)   {|n| "http://link#{n}.factory/"}
    association :item, factory: :event
  end

  factory :page do
    sequence(:filename) {|n| "factory_page_#{n}"}
    title       'Factory Page'
    description 'This is a factory-generated Page.'
    content     '<p>Generated by a Page factory.</p>'
    editor
  end

  # Requires being called with a value for either :item or :redirect
  factory :path do
    sequence(:sitepath) {|n| "/sitepath/factory_sitepath_#{n}"}
  end
  factory :item_path, :parent => :path do
    item { create(:page, :path => self)  }
  end
  factory :redirect_path, :parent => :path do
    redirect '/'
  end

  factory :project do
    creator
    owner
    is_visible true
    sequence(:filename)    {|n| "factory_project_#{n}"}
    sequence(:name)        {|n| "Factory Project #{n}"}
    sequence(:description) {|n| "Factory-generated project ##{n}."}
  end

  factory :setting do
    sequence(:key)   {|n| "factory_key_#{n}"}
    sequence(:value) {|n| "From factory (#{n})."}
  end

  factory :user, aliases: [:creator, :editor, :owner] do
    email
    password              "password"
    password_confirmation "password"
  end
  factory :email_confirmed_user, :parent => :user do |user|
    email_confirmed true
  end

  # item must be supplied
  factory :version do
    user
    edited_at    { (rand(100).hours.ago) }
    title        'Factory Version'
    content      '<p>Generated by a Version factory.</p>'
    content_type 'text/html'
  end
end
