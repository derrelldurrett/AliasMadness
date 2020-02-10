require 'rails_helper'
require 'scenario_factory_spec_setup'

RSpec.describe ScenarioFactory, type: :helper do
  # three "class" methods in ScenarioFactory: ::build_ancestors, ::build_scenarios,
  # and ::score_player.
  # To test we need an admin, its bracket (with games already chosen up to the final
  # three or four games), a group of players (for computational reasons, I'm choosing
  # to do only three), with all of their games chosen, and not at random (as in the rest
  # of the tests). This latter because here we need to know only that the algorithm works
  # at a trivial level of complexity to know it works.
  #
  # Call ScenarioFactory::build_scenarios as ScenarioFactory::build_scenarios_without_delay
  describe '::build_scenarios calculates the remaining results as scenarios' do
    it "gets the correct number of scenarios and results within them" do
      init_brackets
      ScenarioFactory.build_scenarios_without_delay
      scenarios = Scenario.where(remaining_games: 4)
      expect(scenarios.length).to eql(14)
    end
  end
end
