Given %q(An admin who is logged in) do
  login_as_admin
end

When /\AI click the '([^']+)' link\z/ do |link_name|
  click_link link_name
end

Then %q(I should see the initial bracket) do

end
