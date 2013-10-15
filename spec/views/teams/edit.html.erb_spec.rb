require 'spec_helper'

describe "teams/edit" do
  before(:each) do
    @team = assign(:team, stub_model(Team,
      :name => "MyString",
      :seed => 1,
      :label => 1
    ))
  end

  it "renders the edit team form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", team_path(@team), "post" do
      assert_select "input#team_name[name=?]", "team[name]"
      assert_select "input#team_seed[name=?]", "team[seed]"
      assert_select "input#team_label[name=?]", "team[label]"
    end
  end
end
