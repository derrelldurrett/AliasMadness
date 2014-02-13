require 'spec_helper'

describe "admins/new" do
  before(:each) do
    assign(:admin, stub_model(Admin,
      :email => ""
    ).as_new_record)
  end

  it "renders new admin form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", admins_path, "post" do
      assert_select "input#admin_email[name=?]", "admin[email]"
    end
  end
end
