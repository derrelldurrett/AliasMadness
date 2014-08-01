module TransformTeamData
  OLD_NAME,LABEL,NEW_NAME = 1,2,3
  def init
    @team_data=Array.new
    TEAM_DATA.each_line do |t|
      next if t.strip.empty?
      d=t.split '|'
      @team_data<<{old_name: d[OLD_NAME].strip, label: d[LABEL].strip, new_name: d[NEW_NAME].strip}
    end
  end

  def lookup_label_by_team_name(name)
    if @label_by_old_name.nil?
      init_label_by_old_name
    end
    @label_by_old_name[name]
  end

  def init_label_by_old_name
    init
    @label_by_old_name = Hash.new
    @team_data.each do |t|
      @label_by_old_name[t[:old_name]]=t[:label]
    end
  end

  def team_data
    init if @team_data.nil?
    @team_data
  end
  
  def team_data_old_name
    OLD_NAME
  end

  def team_data_new_name
    NEW_NAME
  end

  def team_data_label
    LABEL
  end

  TEAM_DATA=%q(
    | Team 61  | 127   | Colorado              |
    | Team 5   | 126   | North Carolina        |
    | Team 37  | 125   | Utah                  |
    | Team 26  | 124   | George Mason          |
    | Team 57  | 123   | Colorado State        |
    | Team 12  | 122   | New Mexico            |
    | Team 42  | 121   | New Mexico State      |
    | Team 24  | 120   | Weber State           |
    | Team 52  | 119   | Kentucky              |
    | Team 13  | 118   | Illinois              |
    | Team 66  | 117   | Indiana               |
    | Team 17  | 116   | Oregon                |
    | Team 33  | 115   | Washington            |
    | Team 29  | 114   | Arizona               |
    | Team 65  | 113   | UCLA                  |
    | Team 3   | 112   | Northern Colorado     |
    | Team 59  | 111   | Pomona                |
    | Team 7   | 110   | UConn                 |
    | Team 38  | 109   | UMass                 |
    | Team 27  | 108   | Washington State      |
    | Team 58  | 107   | Arizona State         |
    | Team 11  | 106   | Nevada                |
    | Team 43  | 105   | UNLV                  |
    | Team 22  | 104   | Florida               |
    | Team 55  | 103   | Duke                  |
    | Team 14  | 102   | North Carolina State  |
    | Team 46  | 101   | Ohio State            |
    | Team 18  | 100   | Penn                  |
    | Team 35  | 99    | Penn State            |
    | Team 32  | 98    | Gonzaga               |
    | Team 64  | 97    | Davidson              |
    | Team 2   | 96    | Prairie View A&M      |
    | Team 62  | 95    | Texas                 |
    | Team 8   | 94    | Missouri              |
    | Team 39  | 93    | Oklahoma              |
    | Team 28  | 92    | Texas Tech            |
    | Team 68  | 91    | Idaho                 |
    | Team 10  | 90    | Montana               |
    | Team 41  | 89    | Iowa                  |
    | Team 23  | 88    | Iowa State            |
    | Team 53  | 87    | SDSU                  |
    | Team 16  | 86    | Georgia               |
    | Team 51  | 85    | UAB                   |
    | Team 20  | 84    | Louisiana-Lafayette   |
    | Team 36  | 83    | Louisiana State       |
    | Team 31  | 82    | Maryland              |
    | Team 63  | 81    | Menlo                 |
    | Team 4   | 80    | California            |
    | Team 60  | 79    | Stanford              |
    | Team 6   | 78    | Las Positas           |
    | Team 40  | 77    | San Francisco State   |
    | Team 25  | 76    | Hayward State         |
    | Team 56  | 75    | Chico State           |
    | Team 9   | 74    | UC-Davis              |
    | Team 44  | 73    | Southern Cal          |
    | Team 21  | 72    | South Carolina        |
    | Team 54  | 71    | Elon                  |
    | Team 15  | 70    | Oregon State          |
    | Team 49  | 69    | Texas A&M             |
    | Team 19  | 68    | Eastern New Mexico    |
    | Team 34  | 67    | Texas-El Paso         |
    | Team 30  | 66    | Cal State-Northridge  |
    | Team 67  | 65    | Arkansas              |
    | Team 1   | 64    | Kansas State          |
   )
end

World(TransformTeamData)