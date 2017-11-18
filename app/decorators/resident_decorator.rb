class ResidentDecorator < Draper::Decorator

  delegate_all

  def display_name
    [source.first_name.titleize, source.last_name.titleize].join(' ')
  end

  def display_active
    source.active? ? '✓' : "<em class='text-muted'>–</em>".html_safe
  end

end