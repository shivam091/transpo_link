# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

{
  en: {
    direction: "en",
    title: "TranspoLink",
    activerecord: {
      attributes: {
        role: {
          name: "Name",
          is_active: "Is active",
        },
        user: {
          email: "Email address",
          current_password: "Current password",
          password: "Password",
          password_confirmation: "Password confirmation",
          remember_me: "Keep me signed in",
          is_banned: "Is banned",
          is_active: "Is active",
        },
        user_detail: {
          user_id: "User",
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
          address1: "Flat, House no., Building, Company, Apartment, P.O. box, c/o",
          address2: "Area, Street, Sector, Village, Suite, or Floor",
          city: "Town, City, Suburb, or Area",
          state: "State, Province, County, or Territory",
          country: "Country or region",
          postal_code: "Postal code, Postcode, or PIN code",
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
      edit: "Edit",
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
        invalid: "It looks like your email and password combination isn't quite right, please try again.",
        locked: "Your account is locked either due to excessive failed attempts. Please communicate with administrator for further assistance.",
        last_attempt: "You have left one more attempt and your account access will be locked if this attempt is failed.",
        timeout: "Unfortunately your session is expired due to inactivity for a long time. Please sign in again to pickup from where you left off.",
        unauthenticated: "You need to sign in or sign up before continuing.",
        unconfirmed: "You need to verify your email address before sign in. Please check your inbox and spam folder for mail regarding email verification instructions and if you did not receive the instructions, please click on 'Didn't receive verification instructions' link on below side.",
        suspended: "Your account is suspended. If you believe your account was suspended by mistake, please communicate with administrator for further assistance.",
        not_found_with_email_address: "We could not find an account with that email address.",
        not_found_with_email_address_and_password: "We could not find an account with that email address and password.",
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
        already_signed_out: "You are already signed out of your account. Please sign in again.",
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
    layouts: {
      devise: {
        title: "TranspoLink",
        footer: {
          copyright_notice: "&copy; %{copyright_year}, TranspoLink LLP or its affiliates, all rights reserved.",
        },
      },
      application: {
      },
      top_menu: {
        change_to_dark_mode: "Change to dark mode",
        change_to_light_mode: "Change to light mode",
        switch_screen_mode: "Switch screen mode",
        notifications: "Notifications",
        change_language: "Change language",
        toggle_navigation: "Toogle navigation",
        main_navigation: "Main navigation",
        dashboard: "Dashboard",
        users: "Users",
        buyers: "Buyers",
        suppliers: "Suppliers",
      },
      main_navigation: {
      },
      secondary_navigation:{
        secondary_navigation: "Secondary navigation",
        commodities: "Commodities",
        orders: "Orders",
        invoices: "Invoices",
        payments: "Payments",
        vehicles: "Vehicles",
        routes: "Routes",
        warehouses: "Warehouses",
        reports: "Reports",
        feedbacks: "Feedbacks",
      },
      menu: {
        hello_username: "Hello %{username}",
        your_account: "Your account",
        your_profile: "Your profile",
        your_preferences: "Your preferences",
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
    user: {
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
          password_reset_note: "Enter the email address associated with your Invoika account.",
        },
        edit: {
          title: "Create new password",
          create_new_password: "Create new password",
          you_will_be_asked_for_new_password: "We'll ask for this password whenever you sign in.",
          after_password_reset_redirect_note: "After a successful password update, you will be redirected to the login page where you can log in with your new password.",
        }
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
        edit_profile_details: "Edit your profile details viz., first name, last name, address, etc.",
        full_name: "Full name",
        address: "Address",
        mobile_number_help_text: "Quickly receive security notifications with this mobile number.",
      },
    },
  },
}
