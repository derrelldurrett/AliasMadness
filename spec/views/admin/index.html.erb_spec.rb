require 'spec_helper'

describe "admins/index" do
  before(:each) do
    assign(:admin, [
      stub_model(Admin,
        :email => ""
      ),
      stub_model(Admin,
        :email => ""
      )
    ])
  end

  it "renders a list of admins" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "".to_s, :count => 2
  end
end
