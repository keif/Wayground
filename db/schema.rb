# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 12) do

  create_table "authentications", :force => true do |t|
    t.integer  "user_id"
    t.string   "provider",    :null => false
    t.string   "uid",         :null => false
    t.string   "nickname"
    t.string   "name"
    t.string   "email"
    t.string   "location"
    t.string   "url"
    t.string   "image_url"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authentications", ["provider", "uid"], :name => "auth", :unique => true
  add_index "authentications", ["user_id", "provider"], :name => "user"

  create_table "authorities", :force => true do |t|
    t.integer  "user_id"
    t.integer  "authorized_by_id"
    t.integer  "item_id"
    t.string   "item_type"
    t.string   "area",             :limit => 31
    t.boolean  "is_owner"
    t.boolean  "can_create"
    t.boolean  "can_view"
    t.boolean  "can_update"
    t.boolean  "can_delete"
    t.boolean  "can_invite"
    t.boolean  "can_permit"
    t.boolean  "can_approve"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "authorities", ["area", "user_id"], :name => "area"
  add_index "authorities", ["authorized_by_id", "user_id", "area"], :name => "authorizer"
  add_index "authorities", ["item_id", "item_type", "user_id"], :name => "item"
  add_index "authorities", ["user_id", "item_id", "item_type", "area"], :name => "user_map", :unique => true

  create_table "datastores", :force => true do |t|
    t.binary "data", :limit => 133169152, :null => false
  end

  create_table "documents", :force => true do |t|
    t.integer  "datastore_id"
    t.integer  "container_path_id"
    t.integer  "user_id"
    t.boolean  "is_authority_controlled",                 :default => false, :null => false
    t.string   "filename",                :limit => 127,                     :null => false
    t.integer  "size",                                                       :null => false
    t.string   "content_type",                                               :null => false
    t.string   "charset",                 :limit => 31
    t.string   "description",             :limit => 1023
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "documents", ["container_path_id", "filename"], :name => "pathname", :unique => true
  add_index "documents", ["datastore_id"], :name => "data"
  add_index "documents", ["filename"], :name => "file"
  add_index "documents", ["user_id", "filename"], :name => "userfile"

  create_table "events", :force => true do |t|
    t.integer  "user_id"
    t.datetime "start_at",                                                    :null => false
    t.datetime "end_at"
    t.string   "timezone",                 :limit => 31
    t.boolean  "is_allday",                                :default => false, :null => false
    t.boolean  "is_draft",                                 :default => false, :null => false
    t.boolean  "is_approved",                              :default => false, :null => false
    t.boolean  "is_wheelchair_accessible",                 :default => false, :null => false
    t.boolean  "is_adults_only",                           :default => false, :null => false
    t.boolean  "is_tentative",                             :default => false, :null => false
    t.boolean  "is_cancelled",                             :default => false, :null => false
    t.boolean  "is_featured",                              :default => false, :null => false
    t.string   "title",                                                       :null => false
    t.string   "description",              :limit => 511
    t.text     "content",                  :limit => 8191
    t.string   "organizer"
    t.string   "organizer_url"
    t.string   "location"
    t.string   "address"
    t.string   "city"
    t.string   "province",                 :limit => 31
    t.string   "country",                  :limit => 2
    t.string   "location_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "events", ["start_at", "end_at", "is_allday", "is_approved", "is_draft", "is_cancelled"], :name => "dates"
  add_index "events", ["title"], :name => "index_events_on_title"
  add_index "events", ["user_id"], :name => "index_events_on_user_id"

  create_table "external_links", :force => true do |t|
    t.integer  "item_id",                                       :null => false
    t.string   "item_type",                                     :null => false
    t.boolean  "is_source",                  :default => false, :null => false
    t.integer  "position"
    t.string   "site",       :limit => 31
    t.string   "title",                                         :null => false
    t.text     "url",        :limit => 1023,                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "external_links", ["item_type", "item_id"], :name => "index_external_links_on_item_type_and_item_id"
  add_index "external_links", ["site"], :name => "site"
  add_index "external_links", ["title"], :name => "title"

  create_table "pages", :force => true do |t|
    t.integer  "parent_id"
    t.boolean  "is_authority_controlled", :default => false, :null => false
    t.string   "filename",                                   :null => false
    t.string   "title",                                      :null => false
    t.text     "description"
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pages", ["parent_id", "filename"], :name => "path", :unique => true

  create_table "paths", :force => true do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.text     "sitepath",   :null => false
    t.text     "redirect"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "paths", ["item_type", "item_id"], :name => "item_idx"
  add_index "paths", ["sitepath"], :name => "sitepath", :unique => true

  create_table "settings", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["key"], :name => "key", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash",        :limit => 128
    t.string   "name"
    t.boolean  "is_verified_realname",                :default => false, :null => false
    t.boolean  "email_confirmed",                     :default => false, :null => false
    t.string   "confirmation_token",   :limit => 128
    t.string   "remember_token",       :limit => 128
    t.string   "filename",             :limit => 63
    t.string   "timezone",             :limit => 31
    t.string   "location"
    t.text     "about"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "email", :unique => true
  add_index "users", ["filename"], :name => "filename", :unique => true
  add_index "users", ["remember_token"], :name => "remember_token", :unique => true

  create_table "versions", :force => true do |t|
    t.integer  "item_id",      :null => false
    t.string   "item_type",    :null => false
    t.integer  "user_id",      :null => false
    t.datetime "edited_at",    :null => false
    t.string   "edit_comment"
    t.string   "filename"
    t.string   "title"
    t.text     "url"
    t.text     "description"
    t.text     "content"
    t.string   "content_type"
    t.date     "start_on"
    t.date     "end_on"
  end

  add_index "versions", ["edited_at", "item_type", "item_id"], :name => "edits_by_date"
  add_index "versions", ["item_type", "item_id", "edited_at"], :name => "item_by_date"
  add_index "versions", ["user_id", "edited_at", "item_type", "item_id"], :name => "user_by_date"
  add_index "versions", ["user_id", "item_type", "item_id", "edited_at"], :name => "user_by_item"

end
