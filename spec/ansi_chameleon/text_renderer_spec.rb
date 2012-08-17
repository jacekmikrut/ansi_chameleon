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

    describe "for text without tags" do
      let(:text) { "This is some text." }

      it "should push push proper text chunks, but no tags to text_rendering object" do
        text_rendering.should_receive(:push_text).with("This" ).ordered
        text_rendering.should_receive(:push_text).with(" "    ).ordered
        text_rendering.should_receive(:push_text).with("is"   ).ordered
        text_rendering.should_receive(:push_text).with(" "    ).ordered
        text_rendering.should_receive(:push_text).with("some" ).ordered
        text_rendering.should_receive(:push_text).with(" "    ).ordered
        text_rendering.should_receive(:push_text).with("text.").ordered

        subject.render(text)
      end
    end

    describe "for text with multiple whitespaces" do
      let(:text) { "  \tSome  text. " }

      it "should push push separate text chunk for every whitespace character" do
        text_rendering.should_receive(:push_text).with(" "    ).ordered
        text_rendering.should_receive(:push_text).with(" "    ).ordered
        text_rendering.should_receive(:push_text).with("\t"   ).ordered
        text_rendering.should_receive(:push_text).with("Some" ).ordered
        text_rendering.should_receive(:push_text).with(" "    ).ordered
        text_rendering.should_receive(:push_text).with(" "    ).ordered
        text_rendering.should_receive(:push_text).with("text.").ordered
        text_rendering.should_receive(:push_text).with(" "    ).ordered

        subject.render(text)
      end
    end

    describe "for text with tags surrounded by whitespaces" do
      let(:text) { "Outside <tag> inside </tag> outside." }
      let(:tag_names) { [:tag] }

      it "should push push proper text and tag chunks" do
        text_rendering.should_receive(:push_text       ).with("Outside"  ).ordered
        text_rendering.should_receive(:push_text       ).with(" "        ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag"      ).ordered
        text_rendering.should_receive(:push_text       ).with(" "        ).ordered
        text_rendering.should_receive(:push_text       ).with("inside"   ).ordered
        text_rendering.should_receive(:push_text       ).with(" "        ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag"      ).ordered
        text_rendering.should_receive(:push_text       ).with(" "        ).ordered
        text_rendering.should_receive(:push_text       ).with("outside." ).ordered

        subject.render(text)
      end
    end

    describe "for text with tags surrounded immediately by text" do
      let(:text) { "Outside<tag>inside</tag>outside." }
      let(:tag_names) { [:tag] }

      it "should push push proper text and tag chunks" do
        text_rendering.should_receive(:push_text       ).with("Outside"  ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag"      ).ordered
        text_rendering.should_receive(:push_text       ).with("inside"   ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag"      ).ordered
        text_rendering.should_receive(:push_text       ).with("outside." ).ordered

        subject.render(text)
      end
    end

    describe "for text that starts and ends with tags" do
      let(:text) { "<tag>inside</tag>" }
      let(:tag_names) { [:tag] }

      it "should push push proper text and tag chunks" do
        text_rendering.should_receive(:push_opening_tag).with("tag"      ).ordered
        text_rendering.should_receive(:push_text       ).with("inside"   ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag"      ).ordered

        subject.render(text)
      end
    end

    describe "for text with tags of empty content" do
      let(:text) { "Outside <tag></tag> outside." }
      let(:tag_names) { [:tag] }

      it "should push push proper text and tag chunks" do
        text_rendering.should_receive(:push_text       ).with("Outside" ).ordered
        text_rendering.should_receive(:push_text       ).with(" "       ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag"     ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag"     ).ordered
        text_rendering.should_receive(:push_text       ).with(" "       ).ordered
        text_rendering.should_receive(:push_text       ).with("outside.").ordered

        subject.render(text)
      end
    end

    describe "for text with nested tags" do
      let(:text) { "Outside <tag1><tag2>inside</tag2>inside</tag1> outside." }
      let(:tag_names) { [:tag1, :tag2] }

      it "should push push proper text and tag chunks" do
        text_rendering.should_receive(:push_text       ).with("Outside" ).ordered
        text_rendering.should_receive(:push_text       ).with(" "       ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag1"    ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag2"    ).ordered
        text_rendering.should_receive(:push_text       ).with("inside"  ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag2"    ).ordered
        text_rendering.should_receive(:push_text       ).with("inside"  ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag1"    ).ordered
        text_rendering.should_receive(:push_text       ).with(" "       ).ordered
        text_rendering.should_receive(:push_text       ).with("outside.").ordered

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
