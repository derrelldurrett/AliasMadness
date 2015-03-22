module BracketsHelper

  def left_or_right_node(node)
    node_string=''
    n=node.to_i
    if (n % 2) == 1
      case n
        when 96..127
          node_string=' left_connect'
        when 64..95
          node_string=' right_connect'
        when 48..63
          node_string=' left_connect'
        when 32..47
          node_string=' right_connect'
        when 24..31
          node_string=' left_connect'
        when 16..23
          node_string=' right_connect'
        when 12..15
          node_string=' left_connect'
        when 8..11
          node_string=' right_connect'
        when 6, 7, 3
          node_string=' left_connect'
        when 4, 5, 2
          node_string=' right_connect'
      end
    end
    node_string
  end
end
