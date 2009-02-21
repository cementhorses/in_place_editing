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
                  :object_getter => nil,
                  :object_finder => :find,
                  :object_finder_param => :id,
                  :attribute_formatter => :to_s,
                  :object_attribute_formatter => nil,
                  :helper_formatter => nil
                }.merge!(options)
      define_method("set_#{object}_#{attribute}") do
        @item = if options[:object_getter]
          self.send(options[:object_getter])
          self.instance_variable_get("@#{object.to_s}}")
        else
          object.to_s.camelize.constantize.send(options[:object_finder], params[options[:object_finder_param]])
        end
        @item.update_attributes(attribute => params[:value])
        @item.reload
        text = if options[:object_attribute_formatter]
          @item.send(options[:object_attribute_formatter])
        elsif options[:attribute_formatter]
          @item.send(attribute).send(options[:attribute_formatter])
        else
          @item.send(attribute)
        end
        text = @template.send(options[:helper_formatter], text) if options[:helper_formatter]
        render :text => text
      end
    end
  end
end
