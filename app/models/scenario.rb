class Scenario
  include ActiveModel::Model
  attr_accessor :scenario_list, :result

  def initialization
    @scenario_list = []
    @result = []
  end
end