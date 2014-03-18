Given %q(An admin who is logged in) do
  login_as_admin
end


When %q{I visit the page} do
  visit @link
end
