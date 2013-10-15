require 'spec_helper'

team_string_format = /\A[\w.]+\s\(\d{1,2}\)\z/i
describe Team do
  team_specs = {}
  before do
    team_specs = { name: 'Colorado', seed: 12, label: '32' }
    @team = Team.new(team_specs)
    @team.save!
  end
  context 'Team behavior' do
    subject { @team }

    it { should respond_to(:name, :seed, :label) }
    it { should_not be_nil }
    it { should be_valid }
    its(:to_s) { should match team_string_format }

    it { should respond_to(:clone) }
    it { should == @team.clone }
    it { should eql(@team.clone) }
  end

  context 'Cannot create a second instance of the same Team that is not the same object' do
    subject { Team.new(team_specs) }
    it { should_not be_valid }
  end
end
