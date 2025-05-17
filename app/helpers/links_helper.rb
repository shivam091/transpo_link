# -*- encoding: utf-8 -*-
# -*- frozen_string_literal: true -*-
# -*- warn_indent: true -*-

##
# Helper methods for manipulating with links.
#
module LinksHelper
  # While similarly named to Rails's `link_to_if`, this method behaves quite differently.
  # If `condition` is truthy, a link will be returned with the result of the block
  # as its body. If `condition` is falsy, only the result of the block will be returned.
  def conditional_link_to(condition, options, html_options = {}, &block)
    if condition
      link_to options, html_options, &block
    else
      capture(&block)
    end
  end

  def link_to_model(model, label_method: :name, path_method: nil, namespace: nil, **options)
    return unless model

    label = resolve_label(model, label_method)
    path = resolve_path(model, path_method:, namespace:)

    link_to(label, path, **options)
  end

  def link_to_polymorphic(model, label_method: :name, namespace: nil, **options)
    return unless model

    label = resolve_label(model, label_method)
    path  = polymorphic_path([*Array(namespace), model])

    link_to(label, path, **options)
  end

  # Renders a link to the given product
  def link_to_product(product, **options)
    link_to_model(product, **options)
  end

  # Renders a link to the given warehouse
  def link_to_warehouse(warehouse, **options)
    link_to_model(warehouse, **options)
  end

  # Renders a link to the given user
  def link_to_user(user, **options)
    link_to_model(user, label_method: :full_name, **options)
  end

  private

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end

  def resolve_label(model, label_method)
    if label_method.respond_to?(:call)
      label_method.call(model)
    else
      model.respond_to?(label_method) ? model.public_send(label_method) : model.to_s
    end
  end

  def resolve_path(model, path_method:, namespace:)
    if path_method.respond_to?(:call)
      path_method.call(model)
    elsif path_method.present?
      url_helpers.public_send(path_method, model)
    elsif namespace.present?
      url_helpers.public_send("#{namespace}_#{model.model_name.singular}_path", model)
    else
      url_helpers.polymorphic_path(model)
    end
  end
end
