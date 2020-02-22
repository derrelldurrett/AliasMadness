class CableErbParser
  ERB_SUFFIX = '.erb'.freeze
  CABLE_YML = 'config/cable.yml'.freeze

  def parse(yml = CABLE_YML)
    f = File.new("#{Rails.root}/#{yml}", 'w'.freeze)
    f.write(ERB.new(File.read("#{Rails.root}/#{yml + ERB_SUFFIX}")).result)
    f.close
  end
end

CableErbParser.new.parse