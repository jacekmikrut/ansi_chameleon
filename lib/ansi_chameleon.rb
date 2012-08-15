require "ansi_chameleon/version"
require "ansi_chameleon/array_utils"
require "ansi_chameleon/sequence_generator"
require "ansi_chameleon/style_property_name_translator"
require "ansi_chameleon/style_sheet_handler"
require "ansi_chameleon/text_rendering"
require "ansi_chameleon/text_renderer"
require "ansi_chameleon/tag"

module AnsiChameleon

  def self.render(text, style_sheet)
    TextRenderer.new(style_sheet).render(text)
  end
end
