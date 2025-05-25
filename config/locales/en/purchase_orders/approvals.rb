# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

{
  en: {
    purchase_orders: {
      approvals: {
        new: {
          title: "Confirm %{reference_code} approval"
        },
        form: {
          description_html: (<<~HTML).strip,
            <p>
              Please provide the required details such as expected delivery date, payment terms, or reference document to confirm approval of <strong>%{reference_code}</strong>.
            </p>
          HTML
          select_incoterm_code: "Select incoterm code",
          select_shipping_method: "Select shipping method",
          reference_document_help_text: "Enter your internal reference ID for this order (e.g., sales order, confirmation number). Helps align records between you and the buyer (warehouse).",
          expected_delivery_date_help_text: "Specify the date you expect to deliver the order. This helps the buyer plan inventory and operations.",
          incoterm_code_help_text: "Select the delivery agreement between you and the buyer that defines who is responsible for shipping, insurance, customs clearance, and final delivery.",
          shipping_method_help_text: "Select the expected shipping mode for this order (e.g., SEA, ROAD). This may differ from actual delivery method.",
          payment_terms_help_text: "Specify the payment terms for this order (e.g., Net 30, advance, cash on delivery). This ensures financial alignment before processing.",
          remarks_help_text: "Add any additional instructions, clarifications, or notes related to this order.",
          partial_delivery_allowed_help_text: "Indicate if you'll deliver items within this order in parts. This is useful in case full stock isn't available immediately.",
        },
      }
    }
  }
}
