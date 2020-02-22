module BracketsHelper
  def common_bracket_update(id, params)
    if params[:game_data].nil?
      flash[:error]= 'Request FAILED!'
      respond_with false, {status: 400}
    else
      if game_data_processed? params[:game_data], id
        flash[:success]= 'Games saved!'
        respond_with true, {status: 204}
      else
        flash[:error]= 'Games NOT SAVED!'
        respond_with false, {status: 400}
      end
    end
  end

  def players_brackets_locked?
    players= User.where({role: :player}).all
    players_with_locked_brackets= players.where(bracket_locked: 'true').all
    players.length == players_with_locked_brackets.length
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

  def json_to_html(jsn)
    JSON.parse(jsn).join('<br>')
  end
end