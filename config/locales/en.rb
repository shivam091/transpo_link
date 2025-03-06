# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

{
  en: {
    lang: "en",
    direction: "ltr",
    title: "TranspoLink",
    boolean: {
      "yes": "Yes",
      "no": "No",
      nil: "Nothing",
    },
    datetime: {
      time_ago: {
        about_x_seconds_ago: {
          zero: "just now",
          one: "about a second ago",
          other: "about %{count} seconds ago"
        },
        about_x_minutes_ago: {
          one: "about a minute ago",
          other: "about %{count} minutes ago"
        },
        about_x_hours_ago: {
          one: "about an hour ago",
          other: "about %{count} hours ago"
        },
        about_x_days_ago: {
          one: "about a day ago",
          other: "about %{count} days ago"
        },
        about_x_weeks_ago: {
          one: "about a week ago",
          other: "about %{count} weeks ago"
        },
        about_x_weeks_and_x_days_ago: {
          one: "about %{weeks} weeks and a day ago",
          other: "about %{weeks} weeks and %{count} days ago"
        },
        about_x_months_ago: {
          one: "about a month ago",
          other: "about %{count} months ago"
        },
        about_x_years_ago: {
          one: "about a year ago",
          other: "about %{count} years ago"
        },
        over_x_years_ago: "over %{count} years ago",
        almost_x_years_ago: "almost %{count} years ago"
      },
      units: {
        seconds: {
          one: "1 second",
          other: "%{count} seconds"
        },
        minutes: {
          one: "1 minute",
          other: "%{count} minutes"
        },
        hours: {
          one: "1 hour",
          other: "%{count} hours"
        },
        days: {
          one: "1 day",
          other: "%{count} days"
        },
        weeks: {
          one: "1 week",
          other: "%{count} weeks"
        },
        months: {
          one: "1 month",
          other: "%{count} months"
        },
        years: {
          one: "1 year",
          other: "%{count} years"
        },
      },
    },
    number: {
      angle: {
        precision: nil,
        strip_insignificant_zeros: true,
        delimiter: ",",
        separator: ".",
        format: "%{n}°",
      },
    },
    activerecord: {
      attributes: {
        role: {
          name: "Name",
          is_active: "Is active",
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
          are_notifications_enabled: "Are notifications enabled",
        },
        address: {
          address1: "Flat, house no., building, company, apartment, P.O. box, c/o",
          address2: "Area, street, sector, village, suite, or floor",
          city: "Town, city, suburb, or area",
          state: "State, province, county, or territory",
          country: "Country or region",
          postal_code: "Postal code, postcode, or PIN code",
        },
        warehouse: {
          name: "Name",
          reference_code: "Reference code",
          email_address: "Email address",
          contact_number: "Contact number",
          description: "Description",
          total_capacity: "Total capacity",
          capacity_unit: "Capacity unit",
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
        tax_detail: {
          user_id: "User",
          tax_type: "Tax type",
          tax_number: "Tax number",
          country: "Country or region",
        },
        tax_rate: {
          country: "Country or region",
          tax_type: "Tax type",
          business_category: "Business category",
          rate: "Rate",
          valid_from: "Valid from",
          valid_to: "Valid to",
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
          tax_detail: {
            attributes: {
              tax_number: {
                uniqueness: "should be unique within the same tax type and country",
              },
              tax_type: {
                inclusion: "'%{value}' is not a valid tax type",
              },
            },
          },
          tax_rate: {
            attributes: {
              base: {
                no_overlapping_tax_rates: "There is already an active tax rate for this country, tax type, and business category in the selected date range",
              },
              tax_type: {
                inclusion: "'%{value}' is not a valid tax type",
                uniqueness: "already exist for this country and business category for selected date range"
              },
              business_category: {
                inclusion: "'%{value}' is not a valid tax type",
              },
              rate: {
                cannot_change_rate_for_active_tax_rate: "cannot be changed for an active tax rate",
              },
              valid_from: {
                greater_than_or_equal_to: "must be today or a future date"
              }
            },
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
    },
    button_texts: {
      sign_in: "Sign in",
      continue: "Continue",
      save_changes: "Save changes",
      add: "Add",
      new: "New",
      create: "Create",
      edit: "Edit",
      update: "Update",
      delete: "Delete",
      remove: "Remove",
      save: "Save",
      cancel: "Cancel",
    },
    common: {
      selected: "%{count} selected",
    },
    devise: {
      confirmations: {
        confirmed: "Your email address has been successfully confirmed.",
        send_instructions: "You will receive an email with instructions for how to confirm your email address in a few minutes.",
        send_paranoid_instructions: "If your email address exists in our database, you will receive an email with instructions for how to confirm your email address in a few minutes.",
      },
      failure: {
        already_authenticated: "You are already signed in.",
        inactive: "Your account is not activated yet.",
        invalid: "It looks like your email address and password combination isn't quite right, please try again.",
        locked: "Your account is locked either due to excessive failed attempts. Please communicate with administrator for further assistance.",
        last_attempt: "You have left one more attempt and your account access will be locked if this attempt is failed.",
        timeout: "Unfortunately your session is expired due to inactivity for a long time. Please sign in again to pickup from where you left off.",
        unauthenticated: "You need to sign in before continuing.",
        unconfirmed: "You need to verify your email address before sign in. Please check your inbox and spam folder for mail regarding email verification instructions and if you did not receive the instructions, please click on 'Didn't receive verification instructions' link on below side.",
        suspended: "Your account is suspended. If you believe your account was suspended by mistake, please communicate with administrator for further assistance.",
        not_found_in_database: "We could not find an account with that email address.",
      },
      mailer: {
        confirmation_instructions: {
          subject: "Confirmation instructions"
        },
        reset_password_instructions: {
          subject: "Reset password instructions"
        },
        unlock_instructions: {
          subject: "Unlock instructions"
        },
        email_changed: {
          subject: "Email Changed"
        },
        password_change: {
          subject: "Password Changed"
        },
      },
      omniauth_callbacks: {
        failure: "Could not authenticate you from %{kind} because \"%{reason}\".",
        success: "Successfully authenticated from %{kind} account."
      },
      passwords: {
        no_token: "You can't access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided.",
        send_instructions: "You will receive an email with instructions on how to reset your password in a few minutes.",
        send_paranoid_instructions: "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.",
        updated: "Your password has been changed successfully. You are now signed in.",
        updated_not_active: "Your password has been changed successfully.",
        not_send_password_reset_instructions: "Failed to send password reset instructions",
        throttle_reset: {
          one: "Password reset instructions can be sent only once in a minute. Please wait a few minutes before you try again.",
          other: "Password reset instructions can be sent only once in %{count} minutes. Please wait a few minutes before you try again.",
        },
        token_invalid: "Your password reset link appears to be invalid. Please request a new link below.",
        token_expired: "Your password reset link has expired. Please generate a new reset password link.",
      },
      registrations: {
        destroyed: "Bye! Your account has been successfully cancelled. We hope to see you again soon.",
        signed_up: "Welcome to TranspoLink! You have signed up successfully.",
        signed_up_but_inactive: "You have signed up successfully. However, we could not sign you in because your account is not yet activated.",
        signed_up_but_locked: "You have signed up successfully. However, we could not sign you in because your account is locked.",
        signed_up_but_unconfirmed: "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.",
        update_needs_confirmation: "You updated your account successfully, but we need to verify your new email address. Please check your email and follow the confirmation link to confirm your new email address.",
        updated: "Your account has been updated successfully.",
        updated_but_not_signed_in: "Your account has been updated successfully, but since your password was changed, you need to sign in again.",
      },
      sessions: {
        signed_in: "Hi %{user_name}, welcome to TranspoLink!",
        signed_out: "You are successfully signed out.",
        already_signed_out: "You are already signed out of your account.",
        missing_email_or_password: "Please enter your email and password",
      },
      unlocks: {
        send_instructions: "You will receive an email with instructions for how to unlock your account in a few minutes.",
        send_paranoid_instructions: "If your account exists, you will receive an email with instructions for how to unlock it in a few minutes.",
        unlocked: "Your account has been unlocked successfully. Please sign in to continue.",
      },
    },
    errors: {
      messages: {
        already_confirmed: "was already confirmed, please try signing in",
        confirmation_period_expired: "needs to be confirmed within %{period}, please request a new one",
        expired: "has expired, please request a new one",
        not_found: "not found",
        not_locked: "was not locked",
        not_saved: {
          one: "1 error prohibited this %{resource} from being saved:",
          other: "%{count} errors prohibited this %{resource} from being saved:",
        },
      },
    },
    enumerations: {
      user_preference: {
        preferred_color_schemes: {
          auto: "System",
          light: "Light",
          dark: "Dark"
        },
      },
      tax_detail: {
        tax_types: {
          vat: "VAT - Value Added Tax",
          gst: "GST - Goods and Services Tax",
          tin: "TIN - Taxpayer Identification Number",
          ein: "EIN - Employer Identification Number",
          ssn: "SSN - Social Security Number",
          itin: "ITIN - Individual Taxpayer Identification Number",
          pan: "PAN - Permanent Account Number",
          tan: "TAN - Tax Deduction and Collection Account Number",
          gstin: "GSTIN - GST Identification Number",
          vatin: "VATIN - VAT Identification Number",
          eori: "EORI - Economic Operators Registration and Identification Number",
          nif: "NIF - Tax Identification Number",
          cif: "CIF - Tax Identification Code",
          siret: "SIRET - Business Identification System",
          siren: "SIREN - Establishment Identification System",
          utr: "UTR - Unique Taxpayer Reference",
          bn: "BN - Business Number",
          qst: "QST - Quebec Sales Tax",
          abn: "ABN - Australian Business Number",
          acn: "ACN - Australian Company Number",
          tfn: "TFN - Tax File Number",
          ird: "IRD - Inland Revenue Department Number",
          rfc: "RFC - Federal Taxpayer Registry",
          cuit: "CUIT - Unique Tax Identification Code",
          cuil: "CUIL - Unique Labor Identification Code",
          ruc: "RUC - Single Taxpayer Registry",
          nit: "NIT - Tax Identification Number",
          cnpj: "CNPJ - National Register of Legal Entities",
          cpf: "CPF - Register of Natural Persons",
          npwp: "NPWP - Taxpayer Identification Number",
          trn: "TRN - Tax Registration Number",
          kra_pin: "KRA_PIN - Kenya Revenue Authority PIN",
          brn: "BRN - Business Registration Number",
          corporate_number: "CORPORATE_NUMBER - Corporate Number",
          my_number: "MY_NUMBER - Individual Tax Number",
          inn: "INN - Taxpayer Identification Number",
          kpp: "KPP - Tax Registration Reason Code",
          ogrn: "OGRN - Principal State Registration Number",
          ogrnip: "OGRNIP - Individual Entrepreneur Registration Number",
          brn_kr: "BRN_KR - Business Registration Number",
          uscc: "USCC - Unified Social Credit Code",
          mst: "MST - Tax Identification Number",
          tin_ph: "TIN_PH - Taxpayer Identification Number",
          tin_th: "TIN_TH - Taxpayer Identification Number",
          uen: "UEN - Unique Entity Number",
        },
      },
      tax_rate: {
        tax_types: {
          vat: "VAT - Value Added Tax",
          gst: "GST - Goods and Services Tax",
          tin: "TIN - Taxpayer Identification Number",
          ein: "EIN - Employer Identification Number",
          ssn: "SSN - Social Security Number",
          itin: "ITIN - Individual Taxpayer Identification Number",
          pan: "PAN - Permanent Account Number",
          tan: "TAN - Tax Deduction and Collection Account Number",
          gstin: "GSTIN - GST Identification Number",
          vatin: "VATIN - VAT Identification Number",
          eori: "EORI - Economic Operators Registration and Identification Number",
          nif: "NIF - Tax Identification Number",
          cif: "CIF - Tax Identification Code",
          siret: "SIRET - Business Identification System",
          siren: "SIREN - Establishment Identification System",
          utr: "UTR - Unique Taxpayer Reference",
          bn: "BN - Business Number",
          qst: "QST - Quebec Sales Tax",
          abn: "ABN - Australian Business Number",
          acn: "ACN - Australian Company Number",
          tfn: "TFN - Tax File Number",
          ird: "IRD - Inland Revenue Department Number",
          rfc: "RFC - Federal Taxpayer Registry",
          cuit: "CUIT - Unique Tax Identification Code",
          cuil: "CUIL - Unique Labor Identification Code",
          ruc: "RUC - Single Taxpayer Registry",
          nit: "NIT - Tax Identification Number",
          cnpj: "CNPJ - National Register of Legal Entities",
          cpf: "CPF - Register of Natural Persons",
          npwp: "NPWP - Taxpayer Identification Number",
          trn: "TRN - Tax Registration Number",
          kra_pin: "KRA_PIN - Kenya Revenue Authority PIN",
          brn: "BRN - Business Registration Number",
          corporate_number: "CORPORATE_NUMBER - Corporate Number",
          my_number: "MY_NUMBER - Individual Tax Number",
          inn: "INN - Taxpayer Identification Number",
          kpp: "KPP - Tax Registration Reason Code",
          ogrn: "OGRN - Principal State Registration Number",
          ogrnip: "OGRNIP - Individual Entrepreneur Registration Number",
          brn_kr: "BRN_KR - Business Registration Number",
          uscc: "USCC - Unified Social Credit Code",
          mst: "MST - Tax Identification Number",
          tin_ph: "TIN_PH - Taxpayer Identification Number",
          tin_th: "TIN_TH - Taxpayer Identification Number",
          uen: "UEN - Unique Entity Number",
        },
        business_categories: {
          b2b: "Business to Business (B2B)",
          b2c: "Business to Consumer (B2C)"
        },
      },
    },
    layouts: {
      devise: {
        title: "TranspoLink",
        footer: {
          copyright_notice: "&copy; %{copyright_year}, TranspoLink LLP or its affiliates, all rights reserved.",
        },
      },
      application: {
        top_menu: {
          change_color_scheme: "Change color scheme",
          switch_screen_mode: "Switch screen mode",
          notifications: "Notifications",
          change_language: "Change language",
          toggle_navigation: "Toogle navigation",
          main_navigation: "Main navigation",
          dashboard: "Dashboard",
          users: "Users",
          request_logs: "Request logs",
        },
        main_navigation: {
        },
        secondary_navigation:{
          secondary_navigation: "Secondary navigation",
          warehouses: "Warehouses",
          products: "Products",
          inventories: "Inventories",
          orders: "Orders",
          invoices: "Invoices",
          payments: "Payments",
          vehicles: "Vehicles",
          routes: "Routes",
          reports: "Reports",
          feedbacks: "Feedbacks",
          tax_rates: "Tax rates",
        },
        menu: {
          hello_username: "Hello %{username}",
          your_account: "Your account",
          your_profile: "Your profile",
          your_preferences: "Your preferences",
          your_tax_details: "Your tax details",
          keyboard_shortcuts: "Keyboard shortcuts",
          sign_out: "Sign out",
        },
        footer: {
          footer: "Footer",
          footer_navigation: "Footer navigation",
          copyright_notice: "&copy; %{copyright_year}, TranspoLink LLP or its affiliates, all rights reserved.",
          terms: "Terms of service",
          privacy: "Privacy policy",
          contact: "Contact",
          support: "Support",
          about: "About",
        },
      },
    },
    pagination: {
      aria_labels: {
        nav: "Pagination",
        first: "First",
        previous: "Previous",
        next: "Next",
        last: "Last",
      },
      first: "&laquo;",
      previous: "&lsaquo;",
      next: "&rsaquo;",
      last: "&raquo;",
      gap: "&hellip;",
      record_info: "Displaying %{start} to %{end} of %{total} in total",
    },
    shared: {
      inline_navigations: {
        all: "All",
        active: "Active",
        inactive: "Inactive",
      },
      address_form_fields: {
        select_country: "Select country or region",
        select_state: "Select state, province, county, or territory",
      },
    },
    flashes: {
      profiles: {
        update: {
          notice: "Your profile was successfully updated.",
          alert: "Your profile could not be updated."
        },
      },
      preferences: {
        update: {
          notice: "Your preferences were successfully updated.",
          alert: "Your preferences could not be updated."
        },
      },
      locales: {
        update: {
          notice: "You've updated your language. Your change might take a while to show everywhere.",
          alert: "Your language could not be updated."
        },
      },
      warehouses: {
        create: {
          notice: "Warehouse was successfully created.",
          alert: "Warehouse could not be created.",
        },
        update: {
          notice: "Warehouse was successfully updated.",
          alert: "Warehouse could not be updated."
        },
        destroy: {
          info: "Warehouse was successfully deleted.",
          alert: "Warehouse could not be deleted."
        },
      },
      tax_details: {
        create: {
          notice: "Tax detail was successfully created.",
          alert: "Tax detail could not be created.",
        },
        update: {
          notice: "Tax detail was successfully updated.",
          alert: "Tax detail could not be updated."
        },
        destroy: {
          info: "Tax detail was successfully deleted.",
          alert: "Tax detail could not be deleted."
        },
      },
      tax_rates: {
        create: {
          notice: "Tax rate was successfully created.",
          alert: "Tax rate could not be created.",
        },
        update: {
          notice: "Tax rate was successfully updated.",
          alert: "Tax rate could not be updated."
        },
        destroy: {
          info: "Tax rate was successfully deleted.",
          alert: "Tax rate could not be deleted."
        },
      },
    },
    measurement_units: {
      categories: {
        area: "Area based",
        count: "Count based",
        weight: "Weight based",
        volume: "Volume based",
        length: "Length based",
      },
      sub_categories: {
        cm²: "Square centimetre (cm²)",
        m²: "Square metre (m²)",
        km²: "Square kilometre (km²)",
        in²: "Square inch (in²)",
        ft²: "Square foot (ft²)",
        yd²: "Square yard (yd²)",
        ac: "Acre (ac)",
        ha: "Hectare (ha)",
        mg: "Milligramme (mg)",
        g: "Gramme (g)",
        kg: "Kilogramme (kg)",
        q: "Quintal (q)",
        t: "Ton (t)",
        lb: "Pound (lb)",
        oz: "Ounce (oz)",
        ml: "Millilitre (ml)",
        L: "Litre (L)",
        item: "Item",
        pack: "Pack",
        box: "Box",
        carton: "Carton",
        pallet: "Pallet",
        bundle: "Bundle",
        dz: "Dozen",
        case: "Case",
        roll: "Roll",
        cm³: "Cubic centimetre (cm³)",
        m³: "Cubic metre (m³)",
        in³: "Cubic inch (in³)",
        ft³: "Cubic foot (ft³)",
        gal: "Gallon (gal)",
        pt: "Pint (pt)",
        qt: "Quart (qt)",
        bbl: "Barrel (bbl)",
        mm: "Millimetre (mm)",
        cm: "Centimetre (cm)",
        m: "Metre (m)",
        km: "Kilometre (km)",
        in: "Inch (in)",
        ft: "Foot (ft)",
        yd: "Yard (yd)",
        mi: "Mile (mi)",
      },
    },
    users: {
      sessions: {
        new: {
          title: "Sign in",
          welcome_sign_in_to_your_account: "Welcome! Sign in to your account",
          sign_in_disclaimer: "This application ‘TranspoLink’ is available only for authorised users. If you are not authorised user, please disconnect the session by closing the browser immediately. By accessing this system, you agree that your actions may be monitored if unauthorised usage is suspected.",
          forget_password: "Forgot password?",
        }
      },
      passwords: {
        new: {
          title: "Password assistance",
          password_assistance: "Password assistance",
          password_reset_note: "Enter the email address associated with your TranspoLink account.",
        },
        edit: {
          title: "Create new password",
          create_new_password: "Create new password",
          you_will_be_asked_for_new_password: "We'll ask for this password whenever you sign in.",
          after_password_reset_redirect_note: "After a successful password update, you will be redirected to the sign in page where you can use your new password.",
        }
      },
      index: {
        title: "Users",
      },
      user: {
        actions: "Actions",
        no_users_to_display: "No users to display",
      },
      show: {
        basic_n_contact_details: "Basic & contact details",
        additional_details: "Additional details"
      },
    },
    dashboards: {
      show: {
        title: "Dashboard",
      },
    },
    profiles: {
      show: {
        title: "Your profile",
        your_profile: "Your profile",
        edit_profile_details: "Edit your personal details viz., first name, last name, address, and more to ensure your profile reflects the latest information.",
        address: "Address",
        mobile_number_help_text: "Quickly receive security notifications with this mobile number.",
      },
      edit: {
        title: "Edit profile",
      },
      form: {
        profile_details: "Profile details",
        address: "Address",
      },
    },
    preferences: {
      show: {
        title: "Your preferences",
        your_preferences: "Your preferences",
        edit_preferences: "Customize your preferences, including color scheme, time zone, language, and other settings to suit your personal experience.",
      },
      edit: {
        title: "Edit preferences",
      },
      form: {
      },
      preference_form: {
        select_preferred_language: "Select language",
        select_time_zone: "Select time zone",
        select_currency: "Select currency",
        language_translation_percentage: "%{language} (%{percent_translated} translated)"
      },
    },
    locales: {
      edit: {
        title: "Change language",
      },
      form: {
        select_preferred_language: "Select preferred language",
        preferred_locale_form_info: "Changes to your preferred language will be reflected across the application. Specify your preferred language from a list of supported languages. This feature is experimental and translations are not complete yet.",
      },
    },
    request_logs: {
      index: {
        title: "Request logs",
      },
      request_log: {
        no_request_logs_to_display: "No request logs to display"
      },
      show: {
        basic_details: "Basic details",
        advanced_details: "Advanced details",
      },
      basic_details: {},
      advanced_details: {},
    },
    warehouses: {
      index: {
        title: "Warehouses"
      },
      active: {
        title: "Active warehouses",
      },
      warehouse: {
        actions: "Actions",
        no_warehouses_to_display: "No warehouses to display",
        delete_warehouse_confirmation_text: "Are you sure you want to delete the warehouse ‘%{warehouse_name}’? All related data may be lost.",
      },
      new: {
        title: "New warehouse",
      },
      edit: {
        title: "Edit warehouse",
      },
      form: {
        basic_details: "Basic details",
        address: "Address",
      },
      warehouse_basic_details_fields: {
        select_capacity_unit: "Select capacity unit",
        select_managers: "Select managers",
        select_suppliers: "Select suppliers",
      },
      show: {},
    },
    tax_details: {
      index: {
        title: "Your tax details",
        your_tax_details: "Your tax details",
        your_tax_details_help_text: "Manage your tax details for different countries. Add multiple tax records based on where your business operates.",
        tax_details_related_help: "These will be used for compliance, invoicing, and taxation purposes. Ensure accuracy to avoid any tax-related issues.",
      },
      tax_detail: {
        no_tax_details_to_display: "No tax details to display",
        delete_tax_detail_confirmation_text: "Are you sure you want to delete this '%{tax_type}' for '%{country}'? This cannot be undone.",
      },
      new: {
        title: "New tax detail",
      },
      edit: {
        title: "Edit tax detail",
      },
      form: {
        select_country: "Select country or region",
        select_tax_type: "Select tax type",
        country_help_text: "For country-specific tax types, the country will be set automatically. For international tax types (VAT, GST, TIN) and regional tax types (VATIN, EORI, RUC, NIT, BRN), please select the applicable country.",
      },
    },
    tax_rates: {
      index: {
        title: "Tax rates",
      },
      tax_rate: {
        actions: "Actions",
        no_tax_rates_to_display: "No tax rates to display",
        delete_tax_rate_confirmation_text: "Are you sure you want to delete this '%{tax_type}' for '%{country}'? This cannot be undone.",
      },
      new: {
        title: "New tax rate",
      },
      edit: {
        title: "Edit tax rate",
      },
      form: {
        select_country: "Select country or region",
        select_tax_type: "Select tax type",
        select_business_category: "Select business category",
        country_help_text: "For country-specific tax types, the country will be set automatically. For international tax types (VAT, GST, TIN) and regional tax types (VATIN, EORI, RUC, NIT, BRN), please select the applicable country.",
      },
    },
  },
}
