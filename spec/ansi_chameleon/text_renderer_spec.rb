require "spec_helper"

describe AnsiChameleon::TextRenderer do

  let(:style_sheet_handler) { stub(:style_sheet_handler, :tag_names => tag_names) }
  let(:tag_names) { [] }

  describe "each instance" do
    let(:style_sheet) { stub(:style_sheet) }
    let(:text_rendering) { stub(:text_rendering, :push_opening_tag => nil, :push_closing_tag => nil, :push_text => nil, :to_s => 'rendered text') }

    it "should create AnsiChameleon::StyleSheetHandler instance and use it for all renderings" do
      AnsiChameleon::StyleSheetHandler.should_receive(:new).with(style_sheet, AnsiChameleon::StylePropertyNameTranslator).once.and_return(style_sheet_handler)
      AnsiChameleon::TextRendering.should_receive(:new).with(style_sheet_handler).twice.and_return(text_rendering)

      text_renderer = AnsiChameleon::TextRenderer.new(style_sheet)
      text_renderer.render('Some text')
      text_renderer.render('Some other text')
    end
  end

  describe "#render" do
    before { AnsiChameleon::StyleSheetHandler.stub(:new => style_sheet_handler) }
    subject { AnsiChameleon::TextRenderer.new(stub(:style_sheet)) }
    before { AnsiChameleon::TextRendering.stub(:new => text_rendering) }
    let(:text_rendering) { stub(:text_rendering, :to_s => rendered_text) }
    let(:rendered_text) { stub(:rendered_text) }

    it "should create AnsiChameleon::TextRendering with the style sheet handler for every call" do
      AnsiChameleon::TextRendering.should_receive(:new).with(style_sheet_handler).exactly(3).times.and_return(text_rendering)
      subject.render("")
      subject.render("")
      subject.render("")
    end

    it "should return the value obtained from the text_rendering#to_s" do
      text_rendering.should_receive(:to_s).once.and_return(rendered_text)
      subject.render("").should == rendered_text
    end

    describe "for empty text" do
      let(:text) { "" }

      it "should not push anything to text_rendering object" do
        text_rendering.should_not_receive(:push_text)
        text_rendering.should_not_receive(:push_opening_tag)
        text_rendering.should_not_receive(:push_closing_tag)

        subject.render(text)
      end
    end

    describe "for a text with some tags" do
      let(:text) { "This <first_tag>is <second_tag>an</second_tag> example</first_tag><third_tag> text.</third_tag>" }
      let(:tag_names) { [:first_tag, :second_tag, :third_tag] }

      it "should push proper data to text_rendering object" do
        text_rendering.should_receive(:push_text       ).with("This"      ).ordered
        text_rendering.should_receive(:push_text       ).with(" "         ).ordered
        text_rendering.should_receive(:push_opening_tag).with("first_tag" ).ordered
        text_rendering.should_receive(:push_text       ).with("is"        ).ordered
        text_rendering.should_receive(:push_text       ).with(" "         ).ordered
        text_rendering.should_receive(:push_opening_tag).with("second_tag").ordered
        text_rendering.should_receive(:push_text       ).with("an"        ).ordered
        text_rendering.should_receive(:push_closing_tag).with("second_tag").ordered
        text_rendering.should_receive(:push_text       ).with(" "         ).ordered
        text_rendering.should_receive(:push_text       ).with("example"   ).ordered
        text_rendering.should_receive(:push_closing_tag).with("first_tag" ).ordered
        text_rendering.should_receive(:push_opening_tag).with("third_tag" ).ordered
        text_rendering.should_receive(:push_text       ).with(" "         ).ordered
        text_rendering.should_receive(:push_text       ).with("text."     ).ordered
        text_rendering.should_receive(:push_closing_tag).with("third_tag" ).ordered

        subject.render(text)
      end
    end

    describe "for a text that contains tags not recognized by the style_sheet_handler" do
      let(:text) { "This <unknown_tag> is a</unknown_tag>text." }
      let(:tag_names) { [] }

      it "should push unknown tags to text_rendering object as normal text" do
        text_rendering.should_receive(:push_text).with("This"                ).ordered
        text_rendering.should_receive(:push_text).with(" "                   ).ordered
        text_rendering.should_receive(:push_text).with("<unknown_tag>"       ).ordered
        text_rendering.should_receive(:push_text).with(" "                   ).ordered
        text_rendering.should_receive(:push_text).with("is"                  ).ordered
        text_rendering.should_receive(:push_text).with(" "                   ).ordered
        text_rendering.should_receive(:push_text).with("a</unknown_tag>text.").ordered

        subject.render(text)
      end
    end

    describe "for a text that contains words that are the same as some tag names" do
      let(:text) { "one two three" }
      let(:tag_names) { [:one, :two, :three] }

      it "should push unknown tags to text_rendering object as normal text" do
        text_rendering.should_receive(:push_text).with("one"  ).ordered
        text_rendering.should_receive(:push_text).with(" "    ).ordered
        text_rendering.should_receive(:push_text).with("two"  ).ordered
        text_rendering.should_receive(:push_text).with(" "    ).ordered
        text_rendering.should_receive(:push_text).with("three").ordered

        subject.render(text)
      end
    end
  end
end
