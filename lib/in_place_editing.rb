module InPlaceEditing
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Example:
  #
  #   # Controller
  #   class BlogController < ApplicationController
  #     in_place_edit_for :post, :title
  #   end
  #
  #   # View
  #   <%= in_place_editor_field :post, 'title' %>
  #
  module ClassMethods
    def in_place_edit_for(object, attribute, options = {})
      options = {
                  :object_getter_method => nil,
                  :object_finder_method => :find,
                  :object_finder_param => :id,
                  :attribute_formatter_method => :to_s,
                  :object_attribute_formatter_method => nil,
                  :helper_formatter_method => nil
                }.merge!(options)
      define_method("set_#{object}_#{attribute}") do
        @item = if options[:object_getter_method]
          self.send(options[:object_getter_method])
          self.instance_variable_get("@#{object.to_s}}")
        else
          object.to_s.camelize.constantize.send(options[:object_finder_method], params[options[:object_finder_param]])
        end
        @item.update_attributes(attribute => params[:value])
        @item.reload
        text = if options[:object_attribute_formatter_method]
          @item.send(options[:object_attribute_formatter_method])
        else
          @item.send(attribute).send(options[:attribute_formatter_method])
        end
        text = self.send(options[:helper_formatter_method], text) if options[:helper_formatter_method]
        render :text => text
      end
    end
  end
end
