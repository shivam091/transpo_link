# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

module TurboStreamHelpers
  def update_form_frame
    update_frame(form_frame_id, form_partial)
  end

  def update_frame(frame_id, partial)
    turbo_stream.update(frame_id, partial: partial)
  end
end
