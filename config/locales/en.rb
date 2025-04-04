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
      measurement_unit: {
        format: "%{n} %{u}",
        precision: 2,
        strip_insignificant_zeros: false,
        delimiter: ",",
        separator: ".",
        units: {
          cm²: {
            one: "sq. centimetre",
            other: "sq. centimetres",
          },
          m²: {
            one: "sq. metre",
            other: "sq. metres",
          },
          km²: {
            one: "sq. kilometre",
            other: "sq. kilometres",
          },
          in²: {
            one: "sq. inch",
            other: "sq. inches",
          },
          ft²: {
            one: "sq. foot",
            other: "sq. feet",
          },
          yd²: {
            one: "sq. yard",
            other: "sq. yards",
          },
          ac: {
            one: "acre",
            other: "acres",
          },
          ha: {
            one: "hectare",
            other: "hectares",
          },
          mg: {
            one: "milligramme",
            other: "milligrammes",
          },
          g: {
            one: "gramme",
            other: "grammes",
          },
          kg: {
            one: "kilogramme",
            other: "kilogrammes",
          },
          q: {
            one: "quintal",
            other: "quintals",
          },
          t: {
            one: "ton",
            other: "tons",
          },
          lb: {
            one: "pound",
            other: "pounds",
          },
          oz: {
            one: "ounce",
            other: "ounces",
          },
          ml: {
            one: "millilitre",
            other: "millilitres",
          },
          L: {
            one: "litre",
            other: "litres",
          },
          item: {
            one: "item",
            other: "items"
          },
          pack: {
            one: "pack",
            other: "packs"
          },
          box: {
            one: "box",
            other: "boxes"
          },
          carton: {
            one: "carton",
            other: "cartons"
          },
          pallet: {
            one: "pallet",
            other: "pallets"
          },
          bundle: {
            one: "bundle",
            other: "bundles"
          },
          dz: {
            one: "dozen",
            other: "dozens"
          },
          case: {
            one: "case",
            other: "cases"
          },
          roll: {
            one: "role",
            other: "roles"
          },
          cm³: {
            one: "cu. centimetre",
            other: "cu. centimetres",
          },
          m³: {
            one: "cu. metre",
            other: "cu. metres",
          },
          in³: {
            one: "cu. inch",
            other: "cu. inches",
          },
          ft³: {
            one: "cu. foot",
            other: "cu. feet",
          },
          gal: {
            one: "gallon",
            other: "gallons",
          },
          pt: {
            one: "pint",
            other: "pints",
          },
          qt: {
            one: "quart",
            other: "quarts",
          },
          bbl: {
            one: "barrel",
            other: "barrels",
          },
          mm: {
            one: "millimetre",
            other: "millimetres",
          },
          cm: {
            one: "centimetre",
            other: "centimetres",
          },
          m: {
            one: "metre",
            other: "metres",
          },
          km: {
            one: "kilometre",
            other: "kilometres",
          },
          in: {
            one: "inch",
            other: "inches",
          },
          ft: {
            one: "foot",
            other: "feet",
          },
          yd: {
            one: "yard",
            other: "yards",
          },
          mi: {
            one: "mile",
            other: "miles",
          },
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
      leave_feedback: "Leave feedback",
      submit: "Submit",
      mark_as_read: "Mark as read",
      view_details: "View details",
      upload: "Upload",
      download: "Download",
      import: "Import",
      export: "Export",
      approve: "Approve",
      reject: "Reject",
    },
  },
}
