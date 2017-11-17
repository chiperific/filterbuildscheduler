class InitSchema < ActiveRecord::Migration[5.1]
  def up
    # These are extensions that must be enabled in order to support this database
    enable_extension "plpgsql"
    create_table "components", force: :cascade do |t|
      t.string "name", null: false
      t.integer "sample_size"
      t.float "sample_weight"
      t.string "common_id"
      t.boolean "completed_tech"
      t.boolean "completed_tech_boxed"
      t.datetime "deleted_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "components_counts", id: false, force: :cascade do |t|
      t.bigint "component_id", null: false
      t.bigint "count_id", null: false
      t.index ["component_id", "count_id"], name: "index_components_counts_on_component_id_and_count_id"
      t.index ["count_id", "component_id"], name: "index_components_counts_on_count_id_and_component_id"
    end
    create_table "components_parts", id: false, force: :cascade do |t|
      t.bigint "component_id", null: false
      t.bigint "part_id", null: false
      t.integer "parts_per_component", default: 1, null: false
      t.index ["component_id", "part_id"], name: "index_components_parts_on_component_id_and_part_id"
      t.index ["part_id", "component_id"], name: "index_components_parts_on_part_id_and_component_id"
    end
    create_table "components_technologies", id: false, force: :cascade do |t|
      t.bigint "component_id", null: false
      t.bigint "technology_id", null: false
      t.integer "components_per_technology", default: 1, null: false
      t.index ["component_id", "technology_id"], name: "index_components_technologies_on_component_id_and_technology_id"
      t.index ["technology_id", "component_id"], name: "index_components_technologies_on_technology_id_and_component_id"
    end
    create_table "counts", force: :cascade do |t|
      t.bigint "components_id"
      t.bigint "parts_id"
      t.bigint "materials_id"
      t.integer "loose_count", default: 0, null: false
      t.integer "unopened_boxes_count", default: 0, null: false
      t.datetime "deleted_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["components_id"], name: "index_counts_on_components_id"
      t.index ["materials_id"], name: "index_counts_on_materials_id"
      t.index ["parts_id"], name: "index_counts_on_parts_id"
    end
    create_table "counts_materials", id: false, force: :cascade do |t|
      t.bigint "count_id", null: false
      t.bigint "material_id", null: false
      t.index ["count_id", "material_id"], name: "index_counts_materials_on_count_id_and_material_id"
      t.index ["material_id", "count_id"], name: "index_counts_materials_on_material_id_and_count_id"
    end
    create_table "counts_parts", id: false, force: :cascade do |t|
      t.bigint "count_id", null: false
      t.bigint "part_id", null: false
      t.index ["count_id", "part_id"], name: "index_counts_parts_on_count_id_and_part_id"
      t.index ["part_id", "count_id"], name: "index_counts_parts_on_part_id_and_count_id"
    end
    create_table "delayed_jobs", force: :cascade do |t|
      t.integer "priority", default: 0, null: false
      t.integer "attempts", default: 0, null: false
      t.text "handler", null: false
      t.text "last_error"
      t.datetime "run_at"
      t.datetime "locked_at"
      t.datetime "failed_at"
      t.string "locked_by"
      t.string "queue"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string "cron"
      t.index ["priority", "run_at"], name: "delayed_jobs_priority"
    end
    create_table "events", force: :cascade do |t|
      t.datetime "start_time", null: false
      t.datetime "end_time", null: false
      t.string "title", null: false
      t.string "description"
      t.integer "min_registrations"
      t.integer "max_registrations"
      t.integer "min_leaders"
      t.integer "max_leaders"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "location_id", null: false
      t.integer "technology_id", null: false
      t.boolean "is_private", default: false, null: false
      t.integer "item_goal"
      t.integer "technologies_built"
      t.datetime "deleted_at"
      t.integer "attendance"
      t.integer "boxes_packed"
      t.index ["deleted_at"], name: "index_events_on_deleted_at"
    end
    create_table "inventories", force: :cascade do |t|
      t.datetime "date", null: false
      t.boolean "reported", default: false, null: false
      t.boolean "receiving", default: false, null: false
      t.datetime "deleted_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "inventories_technologies", id: false, force: :cascade do |t|
      t.bigint "inventory_id", null: false
      t.bigint "technology_id", null: false
      t.index ["inventory_id", "technology_id"], name: "index_inventories_technologies_on_inventory"
      t.index ["technology_id", "inventory_id"], name: "index_inventories_technologies_on_technology"
    end
    create_table "inventories_users", id: false, force: :cascade do |t|
      t.bigint "inventory_id", null: false
      t.bigint "user_id", null: false
      t.index ["inventory_id", "user_id"], name: "index_inventories_users_on_inventory_id_and_user_id"
      t.index ["user_id", "inventory_id"], name: "index_inventories_users_on_user_id_and_inventory_id"
    end
    create_table "locations", force: :cascade do |t|
      t.string "name", null: false
      t.string "address1"
      t.string "address2"
      t.string "city"
      t.string "state"
      t.string "zip"
      t.string "map_url"
      t.string "photo_url"
      t.string "instructions"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deleted_at"
      t.index ["deleted_at"], name: "index_locations_on_deleted_at"
    end
    create_table "materials", force: :cascade do |t|
      t.string "name", null: false
      t.string "supplier"
      t.string "order_url"
      t.integer "price_cents"
      t.string "price_currency", default: "USD", null: false
      t.integer "min_order"
      t.string "order_id"
      t.float "weeks_to_deliver"
      t.datetime "deleted_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "materials_parts", id: false, force: :cascade do |t|
      t.bigint "material_id", null: false
      t.bigint "part_id", null: false
      t.integer "parts_per_material", null: false
      t.index ["material_id", "part_id"], name: "index_materials_parts_on_material_id_and_part_id"
      t.index ["part_id", "material_id"], name: "index_materials_parts_on_part_id_and_material_id"
    end
    create_table "parts", force: :cascade do |t|
      t.string "name", null: false
      t.string "supplier"
      t.string "order_url"
      t.integer "price_cents"
      t.string "price_currency", default: "USD", null: false
      t.integer "min_order"
      t.string "order_id"
      t.string "common_id"
      t.float "weeks_to_deliver"
      t.integer "sample_size"
      t.float "sample_weight"
      t.boolean "made_from_materials", default: false
      t.datetime "deleted_at"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
    end
    create_table "parts_technologies", id: false, force: :cascade do |t|
      t.bigint "part_id", null: false
      t.bigint "technology_id", null: false
      t.integer "parts_per_technology", default: 1, null: false
      t.index ["part_id", "technology_id"], name: "index_parts_technologies_on_part_id_and_technology_id"
      t.index ["technology_id", "part_id"], name: "index_parts_technologies_on_technology_id_and_part_id"
    end
    create_table "registrations", force: :cascade do |t|
      t.integer "user_id", null: false
      t.integer "event_id", null: false
      t.boolean "attended"
      t.boolean "leader", default: false
      t.integer "guests_registered", default: 0
      t.integer "guests_attended", default: 0
      t.string "accommodations", default: ""
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["user_id", "event_id"], name: "index_registrations_on_user_id_and_event_id", unique: true
    end
    create_table "technologies", force: :cascade do |t|
      t.string "name", null: false
      t.string "description"
      t.integer "ideal_build_length"
      t.integer "ideal_group_size"
      t.integer "ideal_leaders"
      t.boolean "family_friendly"
      t.float "unit_rate"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "deleted_at"
      t.string "img_url"
      t.string "info_url"
      t.index ["deleted_at"], name: "index_technologies_on_deleted_at"
    end
    create_table "technologies_users", id: false, force: :cascade do |t|
      t.bigint "user_id", null: false
      t.bigint "technology_id", null: false
      t.index ["technology_id", "user_id"], name: "index_technologies_users_on_technology_id_and_user_id"
      t.index ["user_id", "technology_id"], name: "index_technologies_users_on_user_id_and_technology_id"
    end
    create_table "users", force: :cascade do |t|
      t.string "email", default: "", null: false
      t.string "encrypted_password", default: "", null: false
      t.string "reset_password_token"
      t.datetime "reset_password_sent_at"
      t.datetime "remember_created_at"
      t.integer "sign_in_count", default: 0, null: false
      t.datetime "current_sign_in_at"
      t.datetime "last_sign_in_at"
      t.inet "current_sign_in_ip"
      t.inet "last_sign_in_ip"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "phone"
      t.boolean "is_leader"
      t.boolean "is_admin"
      t.date "signed_waiver_on"
      t.integer "primary_location_id"
      t.string "fname"
      t.string "lname"
      t.datetime "deleted_at"
      t.string "authentication_token", limit: 30
      t.boolean "does_inventory"
      t.boolean "send_notification_emails", default: false
      t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
      t.index ["deleted_at"], name: "index_users_on_deleted_at"
      t.index ["email"], name: "index_users_on_email", unique: true
      t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    end
    add_foreign_key "events", "locations"
    add_foreign_key "events", "technologies"
    add_foreign_key "registrations", "events"
    add_foreign_key "registrations", "users"
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "The initial migration is not revertable"
  end
end