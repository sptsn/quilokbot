class BaseDecorator < Draper::Decorator

  def self.collection_decorator_class
    PaginatingDecorator
  end

  def display_empty_space
    "<em class='text-muted'>–</em>".html_safe
  end

end
