# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

{
  en: {
    inventory_batches: {
      restocks: {
        new: {
          title: "Restock from batch %{batch_number}",
        },
        form: {
          description_html: (<<~HTML).strip,
            <p>
              This form allows you to restock inventory from an existing batch <strong>%{batch_number}</strong>
              when items are returned, corrected, or otherwise returned to usable stock.
              You can only restock up to the quantity that’s available and restockable.
            </p>
            <p>
              When stock levels are low or operational needs demand more availability, restocking from a batch
              can help maintain efficiency without sourcing new inventory.
              Be sure to include a clear comment and note for tracking and audit purposes.
            </p>
          HTML
          select_unit_of_measure: "Select unit of measure",
          quantity_help_text: "Enter the quantity you want to restock from this batch. This must not exceed the available restockable quantity shown above.",
          unit_id_help_text: "Select the unit of measurement for the quantity you're restocking (e.g., items, kilogrammes, liters). Ensure it matches the packaging or measurement you’re using. Unit will be automatically converted to the inventory's base unit if needed.",
          comment_help_text: "Provide a brief comment for this restock. For example, damaged items verified as usable, expired stock revalidated, or over-delivered items being returned to inventory.",
          note_help_text: "Add any additional note or context about this restock entry. This can include reference IDs, return note number, team comments, internal tracking info, etc.",
        },
      }
    }
  }
}
