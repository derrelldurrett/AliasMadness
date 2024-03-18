# frozen_string_literal: true
module BracketsHelper
  def chat_names_as_json
    User.where(role: :player).each_with_object([]) {|u,o| o << [u.chat_name, u.id]}.to_json
  end

  def common_bracket_update(id, params)
    if not params[:team_data].nil?
      if team_data_processed? params[:team_data], id
        flash[:success]= 'Team name saved!'
        respond_with true, {status: 204}
      else
        flash[:error]= 'Team name NOT SAVED!'
        respond_with false, {status: 400}
      end
    elsif not params[:game_data].nil?
      if game_data_processed? params[:game_data], id
        flash[:success]= 'Games saved!'
        respond_with true, {status: 204}
      else
        flash[:error]= 'Games NOT SAVED!'
        respond_with false, {status: 400}
      end
    else
      flash[:error]= 'Request FAILED!'
      respond_with false, {status: 400}
    end
  end

  def heckler(id)
    # "<b>@#{User.find(id).chat_name}:</b> ".html_safe
  end

  def json_to_html(jsn)
    JSON.parse(jsn).join('<br>')
  end

  def left_or_right_node(node)
    node_string=''
    n=node.to_i
    if (n % 2) == 1
      case n
      when 96..127
        node_string=' left_connect'.freeze
      when 64..95
        node_string=' right_connect'.freeze
      when 48..63
        node_string=' left_connect'.freeze
      when 32..47
        node_string=' right_connect'.freeze
      when 24..31
        node_string=' left_connect'.freeze
      when 16..23
        node_string=' right_connect'.freeze
      when 12..15
        node_string=' left_connect'.freeze
      when 8..11
        node_string=' right_connect'.freeze
      when 6, 7, 3
        node_string=' left_connect'.freeze
      when 4, 5, 2
        node_string=' right_connect'.freeze
      end
    end
    node_string
  end

  def players_brackets_locked?
    User.where({role: :player, bracket_locked: false}).empty?
  end

  def tag_heckle_content(heckle)
    # c = heckle.content
    # heckle.targets.each do |t|
    #   c = BracketsHelper.embolden_user(c, t.chat_name, logger )
    # end
    # c.html_safe
  end

  class << self
    def embolden_user(content, target, logger)
      content.gsub(get_regex(target, logger), "<b>@#{target}</b>")
    end

    def get_regex(name, logger)
      @regexen ||= {}
      @regexen[name] ||= Regexp.new "@#{Regexp.quote(name)}(?=(|\\b))"
    end
  end
end