# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

{
  en: {
    activerecord: {
      attributes: {
        role: {
          name: "Name",
          is_active: "Is active",
          created_at: "Created at",
          updated_at: "Updated at",
        },
        request_log: {
          uuid: "UUID",
          uri: "URI",
          method: "HTTP method",
          session_id: "Session ID",
          session_private_id: "Session private ID",
          remote_address: "Remote address",
          elapsed_time: "Elapsed time",
          user_agent: "User agent",
          referrer: "Referrer",
          origin: "Origin",
          memory_usage: "Memory usage",
          cpu_usage: "CPU usage",
          exception: "Exception",
          request_headers: "Request headers",
          response_headers: "Response headers",
          status: "HTTP status",
          response_size: "Response size",
          query_params: "Query parameters",
          ip_info: "IP info",
          user_id: "Accessed by",
          created_at: "Accessed on",
        },
        user: {
          email: "Email address",
          current_password: "Current password",
          password: "Password",
          password_confirmation: "Password confirmation",
          remember_me: "Keep me signed in",
          is_banned: "Is banned",
          is_active: "Is active",
          role_id: "Role",
          last_activity_at: "Last activity at",
          sign_in_count: "Sign in count",
          current_sign_in_at: "Current sign in at",
          last_sign_in_at: "Last sign in at",
          current_sign_in_ip: "Current sign in IP",
          last_sign_in_ip: "Last sign in IP",
          confirmed_at: "Confirmed at",
          confirmation_sent_at: "Confirmation sent at",
          unconfirmed_email: "Unconfirmed email address",
          failed_attempts: "Failed attempts",
          locked_at: "Locked at",
          address: "Address",
          created_at: "User since",
          updated_at: "Last updated at",
        },
        user_detail: {
          user_id: "User",
          full_name: "Full name",
          first_name: "First name",
          last_name: "Last name",
          mobile_number: "Mobile number",
          alternate_contact_number: "Alternate contact number",
          alternate_email: "Alternate email address",
        },
        user_preference: {
          preferred_locale: "Preferred language",
          preferred_time_zone: "Preferred time zone",
          preferred_currency: "Preferred currency",
          preferred_color_scheme: "Preferred color scheme",
          preferred_date_format: "Preferred date format",
          preferred_time_format: "Preferred time format",
          preferred_datetime_format: "Preferred datetime format",
          first_day_of_week: "First day of week",
          are_notifications_enabled: "Are notifications enabled",
          enable_keyboard_shortcuts: "Enable keyboard shortcuts",
        },
        address: {
          address1: "Flat, house no., building, company, apartment, P.O. box, c/o",
          address2: "Area, street, sector, village, suite, or floor",
          city: "Town, city, suburb, or area",
          state: "State, province, county, or territory",
          country: "Country or region",
          postal_code: "Postal code, postcode, or PIN code",
        },
        unit: {
          category: "Category",
          symbol: "Symbol",
        },
        unit_conversion: {
          source_unit_id: "Source unit",
          target_unit_id: "Target unit",
          multiplier: "Multiplier",
        },
        warehouse: {
          name: "Name",
          reference_code: "Reference code",
          email_address: "Email address",
          contact_number: "Contact number",
          description: "Description",
          total_capacity: "Total capacity",
          unit_id: "Capacity unit",
          capacity: "Capacity",
          latitude: "Latitude",
          longitude: "Longitude",
          is_active: "Is active",
          created_at: "Created at",
          updated_at: "Updated at",
          address: "Address",
          manager_ids: "Managers",
          supplier_ids: "Suppliers",
        },
        warehouse_manager: {
          warehouse_id: "Warehouse",
          manager_id: "Manager",
        },
        warehouse_supplier: {
          warehouse_id: "Warehouse",
          supplier_id: "Supplier",
        },
        legal_identifier: {
          user_id: "User",
          tax_identifier_type: "Tax identifier type",
          tax_identifier: "Tax identifier",
          entity_type: "Entity type",
          business_identifier_type: "Business identifier type",
          business_identifier: "Business identifier",
          country: "Country or region",
        },
        tax_rate: {
          country: "Country or region",
          tax_identifier_type: "Tax identifier type",
          tax_type: "Tax type",
          business_category: "Business category",
          rate: "Rate",
          valid_from: "Valid from",
          valid_to: "Valid to",
        },
        feedback: {
          reference_code: "Reference code",
          rating: "Rating",
          comment: "Comment",
          is_unread: "Is unread",
          reviewable: "Given for",
          user_id: "Given by",
          created_at: "Submitted at",
        },
        product_category: {
          name: "Name",
          products_count: "Products count",
          parent_category_id: "Parent category",
          is_active: "Is active",
        },
        product: {
          reference_code: "Reference code",
          name: "Name",
          sku: "SKU",
          description: "Description",
          barcode: "Barcode",
          min_stock_threshold: "Min. stock threshold",
          unit_id: "Measurement unit",
          currency: "Currency",
          cost_price: "Cost price",
          product_category_id: "Product category",
          is_active: "Is active",
          created_at: "Created at",
          updated_at: "Updated at",
        },
        product_price: {
          warehouse_id: "Warehouse",
          min_quantity: "Min. quantity",
          unit_id: "Unit",
          cost_price: "Cost price",
          currency: "Currency",
          effective_from: "Effective from",
          effective_until: "Effective until",
          effective_period: "Effective period",
        },
        inventory: {
          reference_code: "Reference code",
          product_id: "Product",
          warehouse_id: "Warehouse",
          tracking_method: "Tracking method",
          unit_id: "Inventory unit",
          average_cost_price: "Average cost price",
          currency: "Currency",
          low_stock_threshold: "Low stock threshold",
          created_at: "Created at",
          updated_at: "Updated at",
        },
        inventory_batch: {
          inventory_id: "Inventory",
          batch_number: "Batch number",
          expiration_date: "Expiration date",
          quantity: "Quantity",
          consumed_quantity: "Consumed quantity",
          unit_id: "Inventory unit",
          cost_price: "Cost price",
          currency: "Currency",
          created_at: "Created at",
          updated_at: "Updated at",
        },
        "inventory/restock" => {
          inventory_batch_id: "Inventory batch",
          quantity: "Quantity",
          unit_id: "Unit",
          comment: "Restock comment",
          note: "Restock note",
        },
        inventory_batch_audit_log: {
          inventory_batch_id: "Inventory batch",
          user_id: "Action by",
          previous_quantity: "Previous quantity",
          new_quantity: "New quantity",
          metadata: "Metadata",
        },
        inventory_movement: {
          inventory_id: "Inventory",
          quantity: "Quantity",
          movement_type: "Movement type",
          unit_id: "Inventory unit",
          unit_cost: "Unit cost",
          total_cost: "Total cost",
          currency: "Currency",
          movement_date: "Movement date",
          metadata: "Metadata",
          created_at: "Created at",
          updated_at: "Updated at",
        },
        inventory_audit_log: {
          inventory_id: "Inventory",
          inventory_movement_id: "Inventory movement",
          user_id: "User",
          movement_type: "Movement type",
          previous_quantity: "Previous quantity",
          new_quantity: "New quantity",
          metadata: "Metadata",
          created_at: "Created at",
          updated_at: "Updated at",
        },
        stock: {
          inventory_id: "Inventory",
          quantity_in_hand: "Quantity in hand",
          quantity_pending_to_buyer: "Quantity pending to buyer",
        },
        replenishment: {
          inventory_id: "Inventory",
          quantity_pending_from_supplier: "Quantity pending from supplier",
        },
        purchase_order: {
          reference_code: "Reference code",
          warehouse_id: "Warehouse",
          manager_id: "Manager",
          supplier_id: "Supplier",
          reference_document: "Reference document",
          order_date: "Ordered at",
          expected_delivery_date: "Expected delivery date",
          actual_delivery_date: "Actual delivery date",
          status: "Status",
          notes: "Notes"
        },
        purchase_order_item: {
          purchase_order_id: "Purchase order",
          product_id: "Product",
          quantity: "Quantity",
          received_quantity: "Received quantity",
          unit_id: "Unit of measure",
          unit_cost: "Unit cost",
          total_cost: "Total cost",
          currency: "Currency",
          status: "Status",
          ordered_quantity: "Ordered quantity",
          remaining_quantity: "Remaining quantity",
        },
        "purchase_order_item/delivery" => {
          quantity: "Quantity",
          unit_id: "Unit of measure",
          comment: "Delivery comment",
          note: "Delivery note",
          reference_document: "Reference document",
        },
      },
      errors: {
        format: "%{attribute} %{message}",
        template: {
          body: "There were problems with the following fields:",
          header: {
            one: "Whoops! There was some problem with your input. Please fix it before continuing:",
            other: "Whoops! There were some problems with your inputs. Please fix them before continuing:"
          }
        },
        models: {
          legal_identifier: {
            attributes: {
              tax_identifier: {
                uniqueness: "should be unique within the same tax identifier type, country, and entity type",
                invalid: "is invalid for selected country and tax identifier type"
              },
              tax_identifier_type: {
                inclusion: "'%{value}' is not a valid tax identifier type",
                invalid: "is not valid for the selected country"
              },
              business_identifier_type: {
                absence: "must not be present when entity type is business",
                inclusion: "'%{value}' is not a valid business identifier type",
                invalid: "is not valid for the selected country"
              },
              business_identifier: {
                absence: "must not be present when entity type is business",
                uniqueness: "should be unique within the same business identifier type and country",
                invalid: "is invalid for selected country and business identifier type"
              },
              entity_type: {
                inclusion: "'%{value}' is not a valid entity type",
              },
              status: {
                inclusion: "'%{value}' is not a valid status",
              },
            },
          },
          tax_rate: {
            attributes: {
              base: {
                no_overlapping_tax_rates: "There is already an active tax rate for this country, tax identifier type, tax type, and business category in the selected date range",
              },
              tax_identifier_type: {
                inclusion: "'%{value}' is not a valid tax identifier type",
                uniqueness: "already exist for this country, tax type, and business category for selected date range",
                invalid: "is not valid for the selected country"
              },
              tax_type: {
                inclusion: "'%{value}' is not a valid tax type",
              },
              business_category: {
                inclusion: "'%{value}' is not a valid business category",
              },
              rate: {
                cannot_change_rate_for_active_tax_rate: "cannot be changed for an active tax rate",
              },
              valid_from: {
                greater_than_or_equal_to: "must be today or a future date"
              }
            },
          },
          product: {
            attributes: {
            },
          },
          product_price: {
            attributes: {
              warehouse_id: {
                unit_category_mismatch: "is incompatible with this product due to a capacity unit mismatch"
              }
            },
          },
          unit: {
            attributes: {
              symbol: {
                uniqueness: "already exists for the selected category"
              },
            }
          },
          unit_conversion: {
            attributes: {
              source_unit_id: {
                uniqueness: "already has conversion for the selected target unit"
              },
              target_unit_id: {
                same_as_source_unit: "must be different from source unit",
                category_mismatch: "must belong to the same category as source unit"
              },
            }
          },
          feedback: {
            attributes: {
              rating: {
                invalid: "must be in steps of 0.5"
              },
            },
          },
          inventory: {
            attributes: {
              product_id: {
                uniqueness: "already has inventory for the selected warehouse",
                incompatible_unit_category: "is incompatible for the selected warehouse"
              },
              unit_id: {
                incompatible_unit_category: "is incompatible for the selected product"
              },
            }
          },
          inventory_batch: {
            attributes: {
              batch_number: {
                uniqueness: "already exists for the selected inventory"
              },
              expiration_date: {
                greater_than_or_equal_to: "must be today or a future date"
              },
            }
          },
          purchase_order: {
            attributes: {
              status: {
                inclusion: "'%{value}' is not a valid status for purchase order",
              },
            }
          },
          purchase_order_item: {
            attributes: {
              product_id: {
                uniqueness: "has already been added to this purchase order",
                unit_category_mismatch: "is incompatible with the selected warehouse due to unit category mismatch",
              },
              status: {
                inclusion: "'%{value}' is not a valid status for purchase order item",
              },
              unit_id: {
                incompatible_unit_category: "is incompatible for the selected product"
              },
            }
          },
          "purchase_order_item/delivery" => {
            attributes: {
              quantity: {
                exceeds_remaining_quantity: "cannot exceed remaining quantity of the purchase order item"
              }
            }
          },
        },
        messages: {
          label_already_exists_at_group_level: "already exists at group level for %{group}. Please choose another one.",
          accepted: "must be accepted",
          any_field: "At least one field of %{one_of_required_fields} must be present",
          blank: "is required",
          present: "must be blank",
          confirmation: "doesn't match %{attribute}",
          empty: "can't be empty",
          equal_to: "must be equal to %{count}",
          even: "must be even",
          exclusion: "is reserved",
          greater_than: "must be greater than %{count}",
          greater_than_or_equal_to: "must be greater than or equal to %{count}",
          inclusion: "is not included in the list",
          invalid: "is invalid",
          less_than: "must be less than %{count}",
          less_than_or_equal_to: "must be less than or equal to %{count}",
          model_invalid: "Validation failed: %{errors}",
          not_a_number: "must be a number",
          not_an_integer: "must be an integer",
          odd: "must be odd",
          required: "must exist",
          taken: "is already in use",
          too_long: {
            one: "is too long (maximum is 1 character)",
            other: "is too long (maximum is %{count} characters)"
          },
          too_short: {
            one: "is too short (minimum is 1 character)",
            other: "is too short (minimum is %{count} characters)"
          },
          wrong_length: {
            one: "must be exactly 1 character long",
            other: "must be exactly %{count} characters long"
          },
          other_than: "must be other than %{count}",
          record_invalid: "Validation failed: %{errors}",
          restrict_dependent_destroy: {
            has_one: "Cannot delete record because a dependent %{record} exists",
            has_many: "Cannot delete record because dependent %{record} exist"
          },
        }
      },
    }
  }
}
