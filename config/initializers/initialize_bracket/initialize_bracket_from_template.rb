require %Q(#{Rails.root}/lib/assets/template_loader)
template_file = %Q(#{Rails.root}/config/initializers/initialize_bracket/aliasmadness_bracket_template.csv)

module InitializeBracketFromTemplate
  extend self
  attr_accessor :template_loader,
                :bracket_specification_file
  #,                :bracket_template_comparator

  def configure(&block)
    config.instance_exec config, &block
  end

  def config
    InitializeBracketFromTemplate
  end

#  def load_template(loader, file)
#    data = File.open(file) { |f| f.readlines }
#    cells_as_match_data = [] # refactor: have this built by ff block
#    data.each do |line|
#      cells = line.chomp.split(',').
#          select { |cell| !cell.nil? && !cell.eql?("") }
#      cells_as_match_data.concat(
#          cells.map { |c| @spec_comp_regex.match(c) })
#    end
#    cells_as_match_data.sort! { |a,b| compare_elements loader, a,b } # rename compare when refactoring...
#    @bracket_structure_data = cells_as_match_data
#  end
#
#  def compare_elements(loader,a,b)
#    loader.compare_elements comparer,a,b
#  end
#
#  def bracket_structure_data
#    @bracket_structure_data
#  end
#
#  def loader
#    @loader ||= @@template_loader
#  end
#
#  def specification_file
#    @specification_file ||= @@template_file
#  end
#
#  def comparer
#    TemplateLoader.compare_elements do |format|
#      @@template_format
#    end
#  end
end
#
InitializeBracketFromTemplate.configure do |config|
  # Not sure what to do here.
  # plan is:
  # 1) read the csv
  # 2) create and return what is now the template_loader's
  # @bracket_structure_data
  config.template_loader=TemplateLoader.new
  config.bracket_specification_file=template_file

  # 3) Store that as a serialized object as the Bracket
  # 4) Probably have to have Game and Team serializations (YAML?)
end
