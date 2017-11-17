class ResidentDecorator < Draper::Decorator

  delegate_all

  def display_name
    [source.first_name.titleize, source.last_name.titleize].join(' ')
  end

end