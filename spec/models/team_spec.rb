require 'spec_helper'

describe Team do
  team_specs = {name: 'Colorado', seed: 12, label: '32'}
  team = Team.new
  team.update!(team_specs)
  context 'behavior' do
    it 'responds to .name, .seed, and .label' do
      expect(team).not_to be_nil
      expect(team.name).to eql('Colorado')
      expect(team.seed).to eql(12)
      expect(team.label).to eql('32')
    end
  end
  it 'should be valid' do
    expect(team).to be_valid
  end
  context 'cloning' do
    clone = team.clone
    it 'clone should not be nil' do
      expect(clone).not_to be_nil
    end
    it 'should == the clone' do
      expect(team == clone)
    end
    it 'should eql() the clone' do
      expect(team).to eql(clone)
    end
  end
  context 'hashing' do
    it "has a non-nil hash" do
      expect(team.hash).not_to be_nil
    end
    it "has a non-zero hash" do
      expect(team.hash).not_to eql(0)
    end
  end
  context 'Different teams are not equal' do
    subject {Team.new({name: 'North Carolina', seed: 1, label: '17'})}
    it {should be_valid}
    it {should_not == team}
  end

  context 'Retrieved Teams should be able to compute a hash' do
    subject {Team.where(name: 'Colorado').first}
    it "has a non-nil hash" do
      expect(subject.hash).to_not be_nil
    end
  end

  context 'Cannot create two team objects with the same name, seed and label' do
    subject {Team.new}
    it 'raises an error to create two of the same team' do
      expect {subject.update! team_specs}.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
