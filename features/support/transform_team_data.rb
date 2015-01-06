module TransformTeamData

  def team_data_old_name
    OLD_NAME-1
  end

  def team_data_new_name
    NEW_NAME-1
  end

  def team_data_label
    LABEL-1
  end

  def team_data_seed
    SEED-1
  end

  def lookup_label_by_old_name(name)
    if @label_by_old_name.nil?
      init_label_by_old_name
    end
    # puts "name: #{name} => label: "+ @label_by_old_name[name]
    @label_by_old_name[name]
  end

  def lookup_label_by_new_name(name)
    if @label_by_new_name.nil?
      init_label_by_new_name
    end
    # puts "name: #{name} => label: "+ @label_by_new_name[name]
    @label_by_new_name[name]
  end

  def team_data
    init_team_data if @team_data.nil?
    @team_data
  end

  def init_team_data
    @team_data=Array.new
    TEAM_DATA.each_line do |t|
      next if t.strip.empty?
      d=t.split '|'
      @team_data<< {
          old_name: d[OLD_NAME].strip,
          label: d[LABEL].strip,
          new_name: d[NEW_NAME].strip,
          seed: d[SEED].strip
      }
    end
  end

  private

  OLD_NAME, LABEL, NEW_NAME, SEED = 1, 2, 3, 4
  def init_label_by_new_name
    init_team_data
    @label_by_new_name = Hash.new
    @team_data.each do |t|
      @label_by_new_name[t[:new_name]]=t[:label]
    end
  end

  def init_label_by_old_name
    init_team_data
    @label_by_old_name = Hash.new
    @team_data.each do |t|
      @label_by_old_name[t[:old_name]]=t[:label]
    end
  end

  TEAM_DATA=%q(
    | Team 61  | 127   | Colorado              | 15
    | Team 5   | 126   | North Carolina        | 2
    | Team 37  | 125   | Utah                  | 10
    | Team 26  | 124   | George Mason          | 7
    | Team 57  | 123   | Colorado State        | 14
    | Team 12  | 122   | New Mexico            | 3
    | Team 42  | 121   | New Mexico State      | 11
    | Team 24  | 120   | Weber State           | 6
    | Team 52  | 119   | Kentucky              | 13
    | Team 13  | 118   | Illinois              | 4
    | Team 66  | 117   | Indiana               | 12
    | Team 17  | 116   | Oregon                | 5
    | Team 33  | 115   | Washington            | 9
    | Team 29  | 114   | Arizona               | 8
    | Team 65  | 113   | UCLA                  | 16
    | Team 3   | 112   | Northern Colorado     | 1
    | Team 59  | 111   | Pomona                | 15
    | Team 7   | 110   | UConn                 | 2 
    | Team 38  | 109   | UMass                 | 10
    | Team 27  | 108   | Washington State      | 7 
    | Team 58  | 107   | Arizona State         | 14
    | Team 11  | 106   | Nevada                | 3 
    | Team 43  | 105   | UNLV                  | 11
    | Team 22  | 104   | Florida               | 6 
    | Team 55  | 103   | Duke                  | 13
    | Team 14  | 102   | North Carolina State  | 4 
    | Team 46  | 101   | Ohio State            | 12
    | Team 18  | 100   | Penn                  | 5 
    | Team 35  | 99    | Penn State            | 9 
    | Team 32  | 98    | Gonzaga               | 8 
    | Team 64  | 97    | Davidson              | 16
    | Team 2   | 96    | Prairie View A&M      | 1 
    | Team 62  | 95    | Texas                 | 15
    | Team 8   | 94    | Missouri              | 2 
    | Team 39  | 93    | Oklahoma              | 10
    | Team 28  | 92    | Texas Tech            | 7 
    | Team 68  | 91    | Idaho                 | 14
    | Team 10  | 90    | Montana               | 3 
    | Team 41  | 89    | Iowa                  | 11
    | Team 23  | 88    | Iowa State            | 6 
    | Team 53  | 87    | SDSU                  | 13
    | Team 16  | 86    | Georgia               | 4 
    | Team 51  | 85    | UAB                   | 12
    | Team 20  | 84    | Louisiana-Lafayette   | 5 
    | Team 36  | 83    | Louisiana State       | 9 
    | Team 31  | 82    | Maryland              | 8 
    | Team 63  | 81    | Menlo                 | 16
    | Team 4   | 80    | California            | 1 
    | Team 60  | 79    | Stanford              | 15
    | Team 6   | 78    | Las Positas           | 2 
    | Team 40  | 77    | San Francisco State   | 10
    | Team 25  | 76    | Hayward State         | 7 
    | Team 56  | 75    | Chico State           | 14
    | Team 9   | 74    | UC-Davis              | 3 
    | Team 44  | 73    | Southern Cal          | 11
    | Team 21  | 72    | South Carolina        | 6 
    | Team 54  | 71    | Elon                  | 13
    | Team 15  | 70    | Oregon State          | 4 
    | Team 49  | 69    | Texas A&M             | 12
    | Team 19  | 68    | Eastern New Mexico    | 5 
    | Team 34  | 67    | Texas-El Paso         | 9 
    | Team 30  | 66    | Cal State-Northridge  | 8 
    | Team 67  | 65    | Arkansas              | 16
    | Team 1   | 64    | Kansas State          | 1 
   )
end

World(TransformTeamData)
