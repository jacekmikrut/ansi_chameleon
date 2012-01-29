require "spec_helper"

describe AnsiChameleon do

  describe ".render" do

    it "should create a new AnsiChameleon::TextRenderer instance and delegate rendering to it" do
      text = stub(:text)
      style_sheet = stub(:style_sheet)

      text_renderer = stub(:text_renderer)
      AnsiChameleon::TextRenderer.should_receive(:new).with(style_sheet).and_return(text_renderer)
      text_renderer.should_receive(:render).with(text)

      AnsiChameleon.render(text, style_sheet)
    end
  end
end
