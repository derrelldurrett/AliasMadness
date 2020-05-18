module ApplicationHelper
  def full_title(page_title)
    base_title = %q(Alia's Madness)
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # @return [true, false]
  # True if all players' brackets that are locked,
  # False otherwise.
  def players_brackets_locked?
    # True if all players' brackets are locked.
    User.where({role: :player}).where(bracket_locked: false).length == 0
  end
end
