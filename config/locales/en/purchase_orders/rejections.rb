# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

{
  en: {
    purchase_orders: {
      rejections: {
        new: {
          title: "Confirm %{reference_code} rejection"
        },
        form: {
          description_html: (<<~HTML).strip,
            <p>
              Please enter the following information to confirm rejection of <strong>%{reference_code}</strong>.
            </p>
            <p>
              The buyer is the warehouse that originally placed this order. Select a valid reason for rejection, and optionally suggest alternatives or include a note to help the buyer fulfill their requirements more effectively.
            </p>
          HTML
          select_reason: "Select reason",
          reason_help_text: "Select the most appropriate reason for rejecting this order. This helps the buyer understand and address the issue efficiently.",
          suggested_alternatives_help_text: "Suggest any alternative items, specifications, delivery timelines, or pricing that could be acceptable. This helps the buyer revise and resubmit the order, if needed.",
          note_help_text: "Add any other supporting details or context to help the buyer understand the rejection. These notes assist in record keeping and future negotiations.",
        },
      }
    }
  }
}
