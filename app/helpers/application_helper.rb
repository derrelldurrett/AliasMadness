module ApplicationHelper
# Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = %q(Alia's Madness)
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # @return [true, if the number of unlocked brackets is 0]
  def players_brackets_locked?
    User.where({role: :player}).where(bracket_locked: false).length == 0
  end

end
