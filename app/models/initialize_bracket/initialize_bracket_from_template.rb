# frozen_string_literal: true
# require_relative './template_loader'
TEMPLATE_FILE = %Q(#{Rails.root}/app/models/initialize_bracket/aliasmadness_bracket_template.csv)

module InitializeBracket
  module InitializeBracketFromTemplate
    extend self
    attr_accessor :template_loader,
                  :bracket_specification_file

    def configure(&block)
      config.instance_exec config, &block
    end

    def config
      InitializeBracketFromTemplate
    end
  end
  #
  InitializeBracketFromTemplate.configure do |config|
    # Not sure what to do here.
    # plan is:
    # 1) read the csv
    # 2) create and return what is now the template_loader's
    # @bracket_structure_data
    config.template_loader = TemplateLoader.instance
    config.bracket_specification_file = TEMPLATE_FILE

    # 3) Store that as a serialized object as the Bracket
    # 4) Probably have to have Game and Team serializations (YAML?)
  end
end