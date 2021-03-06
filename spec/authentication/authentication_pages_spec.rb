require "rspec"
require 'spec_helper'
require 'capybara'
#require 'capybara/rspec'
require 'capybara/rails'

feature "Authentication" do

  let(:admin) { FactoryBot.create(:admin) }
  before do
    visit users_path params(email: admin.email)
  end
  subject { page }

  scenario "signin page" do

    it { should have_selector('h1',    text: %q(Sign in to Alia's Madness)) }
    it { should have_selector('title', text: %q(Sign in to Alia's Madness)) }
  end

  #describe "signin" do
  #  before { visit signin_path }
  #
  #  describe "with invalid information" do
  #    before { click_button "Sign in" }
  #    it { should have_selector('title', text: 'Sign in to Alia\'s Madness') }
  #    it { should have_selector('div.alert.alert-error', text: 'Invalid') }
  #  end
  #
  #  describe "after visiting another page" do
  #    before { click_link "Home" }
  #    it { should_not have_selector('div.alert.alert-error') }
  #  end
  #
  #  describe "with valid information" do
  #    let(:user) { FactoryBot.create(:user) }
  #    before { sign_in user }
  #
  #    it { should have_selector('title', text: user.name) }
  #    it { should have_link('Users',     href: users_path) }
  #    it { should have_link('Profile',   href: user_path(user)) }
  #    it { should have_link('Settings',  href: edit_user_path(user)) }
  #    it { should have_link('Sign out',  href: signout_path) }
  #
  #    it { should_not have_link('Sign in', href: signin_path) }
  #
  #    describe "followed by signout" do
  #      before { click_link "Sign out" }
  #      it { should have_link('Sign in')
  #      }
  #    end
  #  end
  #end

#  describe "authorization" do
#
#    describe "for non-signed-in users" do
#      let(:user) { FactoryBot.create(:user) }
#
#      describe "when attempting to visit a protected page" do
#        before do
#          visit edit_user_path(user)
#          fill_in "Email",    with: user.email
#          fill_in "Password", with: user.password
#          click_button "Sign in"
#        end
#
#        describe "after signing in" do
#
#          it "should render the desired protected page" do
#            page.should          have_selector('title', text: 'Edit user')
#          end
#        end
#      end
#
#      describe "in the Users controller" do
#
#        describe "visiting the edit page" do
#          before { visit edit_user_path(user) }
#          it { should have_selector('title', text: 'Sign in') }
#        end
#
#        describe "submitting to the update action" do
#          before { put user_path(user) }
#          specify { response.should redirect_to(signin_path) }
#        end
#
#        describe "visiting the user index" do
#          before { visit users_path }
#          it { should have_selector('title', text: 'Sign in') }
#        end
#
#        describe "visiting the following page" do
#          before { visit following_user_path(user) }
#          it { should have_selector('title', text: 'Sign in') }
#        end
#
#        describe "visiting the followers page" do
#          before { visit followers_user_path(user) }
#          it { should have_selector('title', text: 'Sign in') }
#        end
#      end
#
#      describe "as wrong user" do
#        let(:user) { FactoryBot.create(:user) }
#        let(:wrong_user) { FactoryBot.create(:user, email: "wrong@example.com") }
#        before { sign_in user }
#
#        describe "visiting Users#edit page" do
#          before { visit edit_user_path(wrong_user) }
#          it { should_not have_selector('title', text: full_title('Edit user')) }
#        end
#
#        describe "submitting a PUT request to the Users#update action" do
#          before { put user_path(wrong_user) }
#          specify { response.should redirect_to(root_path) }
#        end
#      end
#      describe "when attempting to visit a protected page" do
#        before do
#          visit edit_user_path(user)
#          fill_in "Email",    with: user.email
#          fill_in "Password", with: user.password
#          click_button "Sign in"
#        end
#
#        describe "after signing in" do
#
#          it "should render the desired protected page" do
#            page.should have_selector('title', text: 'Edit user')
#          end
#
#          describe "when signing in again" do
#            before do
#              visit signin_path
#              fill_in "Email",    with: user.email
#              fill_in "Password", with: user.password
#              click_button "Sign in"
#            end
#
#            it "should render the default (profile) page" do
#              page.should have_selector('title', text: user.name)
#            end
#          end
#        end
#      end
#
#    describe "as non-admin user" do
#      let(:user) { FactoryBot.create(:user) }
#      let(:non_admin) { FactoryBot.create(:user) }
#
#      before { sign_in non_admin }
#
#      describe "submitting a DELETE request to the Users#destroy action" do
#        before { delete user_path(user) }
#        specify { response.should redirect_to(root_path) }
#      end
#    end
#  end
#end

end
