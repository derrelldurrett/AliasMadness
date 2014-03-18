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

    describe '#to_s' do
      subject { super().to_s }
      it { should match team_string_format }
    end

    it { should respond_to(:clone) }
    it { should == @team.clone }
    it { should eql(@team.clone) }
    its(:hash) {should_not eql(0)}
    its(:hash) {should_not be_nil}
  end

  context 'Cannot create a second instance of the same Team that is not the same object' do
    subject { Team.new(team_specs) }
    it { should_not be_valid }
  end

  context 'Different teams are not equal' do
    subject { Team.new({name: 'North Carolina', seed: 1, label: '17'}) }
    it { should be_valid }
    it { should_not == @team }
  end

  context 'Retrieved Teams should be able to compute a hash' do
    subject { Team.find_by_name('Colorado') }
    its(:hash) {should_not be_nil}
  end
end
