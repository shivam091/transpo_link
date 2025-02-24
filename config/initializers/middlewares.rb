# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

# Be sure to restart your server when you modify this file.

require_relative "../../app/middlewares/request_time_recorder.rb"
require_relative "../../app/middlewares/ip_info.rb"
require_relative "../../app/middlewares/request_logger.rb"

TranspoLink::Application.config.middleware.insert 0, RequestTimeRecorder
TranspoLink::Application.config.middleware.use IpInfo, {ttl: 30, maxsize: 30}
TranspoLink::Application.config.middleware.use RequestLogger
