# frozen_string_literal: true
module UsersHelper
  def update_player_scores
    players = User.players
    if players.length >= 1
      reference = Admin.get.reload.bracket
      players.sort_by do |p|
        p.score reference
        p.reload
      end
      @players = get_players_sorted_by_score
      puts %Q(Players scores updated.)
    end
  end

  def get_players_sorted_by_score
    User.where(role: :player).order('current_score desc')
  end

  def bracket_complete_class(player, is_for_admin)
    complete_class = ''
    if is_for_admin
      games_nil = player.bracket.games.any? {|g| g.winner.nil?}
      complete_class = ' bracket_complete' unless games_nil and !players_brackets_locked?
    end
    complete_class
  end

  def clickable(user)
    User.where({id: user.id}).where(bracket_locked: true) ? 'clickable' : ''
  end

  def create_player params
    params[:role]='player'
    set_player_login params
    @user = User.create!(params)
    @user.update bracket_locked: :false # apparently necessary on heroku, because the tests don't see it
    UserMailer.welcome_email(@user, @remember_for_email).deliver
  end

  def set_player_login(params)
    params[:password] =
        params[:password_confirmation] =
            @remember_for_email =
                SecureRandom.base64(24) #create a  32-character-length password
  end

  def load_users_heckles
    show = Heckle.where(id: HecklesUser.where(user_id: current_user.id).select(:heckle_id))
    all_pairs = HecklesUser.all.select(:heckle_id).distinct
    show += Heckle.where.not(id: all_pairs)
    show.sort_by { |h| h.id }
  end
end