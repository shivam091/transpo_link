# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

{
  en: {
    purchase_order_items: {
      deliveries: {
        new: {
          title: "Confirm delivery"
        },
        form: {
          description_html: (<<~HTML).strip,
            <p>
              Use this form to <strong>record the delivery of a purchase order item</strong>. You can deliver the full or partial quantity received from the supplier.
            </p>
            <p>
              Ensure that all details are accurate. The delivery data affects stock levels, batch tracking, and financial reporting. If delivering in parts, submit the form multiple times as needed.
            </p>
          HTML
          select_unit_of_measure: "Select unit of measure",
          quantity_help_text: "Specify how many quantity of the item you are delivering. This should not exceed the remaining undelivered quantity for this item.",
          unit_id_help_text: "Choose the unit in which the quantity is being delivered. Ensure it matches the packaging or measurement you’re using.",
          comment_help_text: "Provide a short comment on this delivery. For example: “Initial shipment”, “Partial delivery”, or “Backorder fulfillment”.",
          note_help_text: "Add any additional notes or remarks about this delivery. This could include shipment references, delivery personnel, condition on arrival, or quality observations."
        },
      },
    }
  }
}
