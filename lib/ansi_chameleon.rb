require "ansi_chameleon/version"

require "simple_style_sheet"

require "ansi_chameleon/sequence_generator"
require "ansi_chameleon/style_property_name_translator"
require "ansi_chameleon/tag"
require "ansi_chameleon/text_rendering"
require "ansi_chameleon/text_rendering/stack"
require "ansi_chameleon/text_rendering/syntax_validator"
require "ansi_chameleon/text_renderer"

module AnsiChameleon

  def self.render(text, style_sheet)
    TextRenderer.new(style_sheet).render(text)
  end
end
