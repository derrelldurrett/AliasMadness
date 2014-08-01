def invite_player(name,email)
  fill_in 'Name', with: name
  fill_in 'Email', with: email
  click_button('Invite Player')
end

def login_as_admin
  admin = Admin.get
  email = admin.email
  password = 'foobaer'
  link = login_path(email: email)
  visit link
  # save_and_open_page
  fill_in 'Password', with: password
  click_button('Login')
end

def store_team_data
  @look_up_team_id_by_original_data= Hash.new
  teams=Team.all
  teams.each do |t|
    @look_up_team_id_by_original_data[t.name]=t.id
  end
end

def look_up_team_id_by_original_data(data)
  @look_up_team_id_by_original_data[data]
end

def construct_team_css_node_name(label)
  %Q(td.team[data-node="#{label}"])
end

def path_to(page_name)
  case
    when /\Alogin\z/i
      login_path(email: @email)
    else
      raise %Q{Can't find path_to entry for #{pageName}!}
  end
end