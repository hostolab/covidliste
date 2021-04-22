# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_19_230614) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blazer_audits", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.index ["query_id"], name: "index_blazer_audits_on_query_id"
    t.index ["user_id"], name: "index_blazer_audits_on_user_id"
  end

  create_table "blazer_checks", force: :cascade do |t|
    t.bigint "creator_id"
    t.bigint "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.text "slack_channels"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_checks_on_creator_id"
    t.index ["query_id"], name: "index_blazer_checks_on_query_id"
  end

  create_table "blazer_dashboard_queries", force: :cascade do |t|
    t.bigint "dashboard_id"
    t.bigint "query_id"
    t.integer "position"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["dashboard_id"], name: "index_blazer_dashboard_queries_on_dashboard_id"
    t.index ["query_id"], name: "index_blazer_dashboard_queries_on_query_id"
  end

  create_table "blazer_dashboards", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_dashboards_on_creator_id"
  end

  create_table "blazer_queries", force: :cascade do |t|
    t.bigint "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.string "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["creator_id"], name: "index_blazer_queries_on_creator_id"
  end

  create_table "campaign_batches", force: :cascade do |t|
    t.bigint "campaign_id"
    t.bigint "vaccination_center_id"
    t.bigint "partner_id"
    t.integer "size", null: false
    t.integer "duration_in_minutes", default: 10, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["campaign_id"], name: "index_campaign_batches_on_campaign_id"
    t.index ["partner_id"], name: "index_campaign_batches_on_partner_id"
    t.index ["vaccination_center_id"], name: "index_campaign_batches_on_vaccination_center_id"
    t.check_constraint "duration_in_minutes > 0", name: "duration_in_minutes_gt_zero"
    t.check_constraint "size > 0", name: "size_gt_zero"
  end

  create_table "campaigns", force: :cascade do |t|
    t.string "name"
    t.bigint "vaccination_center_id"
    t.bigint "partner_id"
    t.string "vaccine_type", null: false
    t.integer "available_doses", null: false
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.text "extra_info"
    t.integer "min_age", null: false
    t.integer "max_distance_in_meters", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "max_age"
    t.integer "status", default: 0
    t.datetime "canceled_at"
    t.index ["partner_id"], name: "index_campaigns_on_partner_id"
    t.index ["status"], name: "index_campaigns_on_status"
    t.index ["vaccination_center_id"], name: "index_campaigns_on_vaccination_center_id"
    t.check_constraint "(available_doses > 0) AND (available_doses <= 1000)", name: "available_doses_gt_zero"
    t.check_constraint "(max_age > 0) AND (max_age > min_age)", name: "max_age_gt_zero"
    t.check_constraint "(vaccine_type)::text = ANY ((ARRAY['pfizer'::character varying, 'moderna'::character varying, 'astrazeneca'::character varying, 'janssen'::character varying])::text[])", name: "vaccine_type_is_a_known_brand"
    t.check_constraint "max_distance_in_meters > 0", name: "max_distance_in_meters_gt_zero"
    t.check_constraint "min_age > 0", name: "min_age_gt_zero"
    t.check_constraint "starts_at < ends_at", name: "starts_at_lt_ends_at"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "vaccination_center_id"
    t.bigint "campaign_id"
    t.bigint "campaign_batch_id"
    t.bigint "user_id"
    t.datetime "sms_sent_at"
    t.datetime "expires_at"
    t.datetime "confirmed_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "mail_sent_at"
    t.string "match_confirmation_token_ciphertext"
    t.string "match_confirmation_token_bidx"
    t.integer "age"
    t.string "zipcode"
    t.string "city"
    t.string "geo_citycode"
    t.string "geo_context"
    t.datetime "refused_at"
    t.index ["campaign_batch_id"], name: "index_matches_on_campaign_batch_id"
    t.index ["campaign_id"], name: "index_matches_on_campaign_id"
    t.index ["match_confirmation_token_bidx"], name: "index_matches_on_match_confirmation_token_bidx", unique: true
    t.index ["user_id"], name: "index_matches_on_user_id"
    t.index ["vaccination_center_id"], name: "index_matches_on_vaccination_center_id"
  end

  create_table "partner_vaccination_centers", force: :cascade do |t|
    t.bigint "partner_id"
    t.bigint "vaccination_center_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["partner_id", "vaccination_center_id"], name: "idx_partners_vac_centers_on_partner_id_and_vac_center_id"
    t.index ["partner_id"], name: "index_partner_vaccination_centers_on_partner_id"
    t.index ["vaccination_center_id"], name: "index_partner_vaccination_centers_on_vaccination_center_id"
  end

  create_table "partners", force: :cascade do |t|
    t.string "email_ciphertext", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name_ciphertext"
    t.string "phone_number_ciphertext"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "email_bidx"
    t.boolean "statement", default: false
    t.datetime "statement_accepted_at"
    t.index ["confirmation_token"], name: "index_partners_on_confirmation_token", unique: true
    t.index ["email_bidx"], name: "index_partners_on_email_bidx", unique: true
    t.index ["email_ciphertext"], name: "index_partners_on_email_ciphertext", unique: true
    t.index ["reset_password_token"], name: "index_partners_on_reset_password_token", unique: true
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.bigint "resource_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource"
  end

  create_table "users", force: :cascade do |t|
    t.date "birthdate"
    t.float "lat"
    t.float "lon"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "toc"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.text "firstname_ciphertext"
    t.text "lastname_ciphertext"
    t.text "phone_number_ciphertext"
    t.text "address_ciphertext"
    t.text "email_ciphertext"
    t.string "email_bidx"
    t.string "zipcode"
    t.string "city"
    t.string "geo_citycode"
    t.string "geo_context"
    t.datetime "anonymized_at"
    t.boolean "statement", default: false
    t.datetime "statement_accepted_at"
    t.datetime "toc_accepted_at"
    t.index ["city"], name: "index_users_on_city"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token"
    t.index ["email_bidx"], name: "index_users_on_email_bidx", unique: true
    t.index ["geo_citycode"], name: "index_users_on_geo_citycode"
    t.index ["geo_context"], name: "index_users_on_geo_context"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["zipcode"], name: "index_users_on_zipcode"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  create_table "vaccination_centers", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "address"
    t.float "lat"
    t.float "lon"
    t.string "kind"
    t.boolean "pfizer"
    t.boolean "moderna"
    t.boolean "astrazeneca"
    t.boolean "janssen"
    t.datetime "confirmed_at"
    t.string "phone_number"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "confirmer_id"
    t.datetime "disabled_at"
    t.index ["confirmer_id"], name: "index_vaccination_centers_on_confirmer_id"
  end

  add_foreign_key "campaign_batches", "campaigns"
  add_foreign_key "campaign_batches", "partners"
  add_foreign_key "campaign_batches", "vaccination_centers"
  add_foreign_key "campaigns", "partners"
  add_foreign_key "campaigns", "vaccination_centers"
  add_foreign_key "matches", "campaign_batches"
  add_foreign_key "matches", "campaigns"
  add_foreign_key "matches", "users"
  add_foreign_key "matches", "vaccination_centers"
  add_foreign_key "partner_vaccination_centers", "partners"
  add_foreign_key "partner_vaccination_centers", "vaccination_centers"
  add_foreign_key "vaccination_centers", "users", column: "confirmer_id"
end
