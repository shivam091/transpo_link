# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

{
  en: {
    purchase_order_items: {
      inventory_batches: {
        new: {
          title: "New inventory batch"
        },
        form: {
          select_unit: "Select unit",
          description_html: (<<~HTML).strip,
            <p>
              You’re creating a new inventory batch using the delivered quantity from purchase order <strong>%{reference_code}</strong>.
            </p>
            <p>
              You may use the full or a partial quantity to create this batch. Please ensure that batch details—such as lot number, expiry date, and storage location—are entered accurately to support traceability and operational efficiency.
            </p>
          HTML
          batch_number_help_text: "Enter the unique identifier assigned to this batch for internal tracking and traceability. It is often printed on packaging or assigned during receiving.",
          lot_number_help_text: "Provide the lot number as issued by the supplier or manufacturer. This is helpful for compliance, warranty, and recall tracking if applicable.",
          quantity_help_text: "Enter the quantity from the delivered stock that you want to allocate to this batch. You can use the full or partial amount. Make sure this quantity does not exceed what was delivered.",
          unit_id_help_text: "Select the unit of measurement for the quantity you're assigning (e.g., items, kilograms, liters). The system will convert this to the inventory's base unit for consistency.",
          manufactured_at_help_text: "Enter the date this batch was manufactured or produced. Useful for shelf life calculations and traceability.",
          expiration_date_help_text: "If the product is perishable or has a defined shelf life, specify the expiration date. Leave blank if not applicable.",
          received_at_help_text: "Enter the date this batch was physically received in your warehouse. It may differ from the delivery date on the purchase order.",
          location_help_text: "Specify the physical storage location within the warehouse (e.g., Bin A1, Shelf 2). This helps staff locate the stock quickly.",
          notes_help_text: "Add any relevant remarks about this batch — such as supplier conditions, inspection status, or quality concerns. This is for internal reference.",
        },
      },
    }
  }
}
