require "spec_helper"

describe AnsiChameleon::TextRenderer do

  let(:style_sheet_handler) { stub(:style_sheet_handler) }

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

    context "for empty text" do
      let(:text) { "" }

      it "should not push anything to text_rendering object" do
        text_rendering.should_not_receive(:push_text)
        text_rendering.should_not_receive(:push_opening_tag)
        text_rendering.should_not_receive(:push_closing_tag)

        subject.render(text)
      end
    end

    context "for text without tags" do
      let(:text) { "This is some text." }

      it "should push one text chunk and no tags to text_rendering object" do
        text_rendering.should_receive(:push_text).with("This is some text.")

        subject.render(text)
      end
    end

    context "for text with multiple spaces, \\t, \\n and \\r characters" do
      let(:text) { "  \tSome  text. \nSecond line.  \r  " }

      it "should push one text chunk to text_rendering object" do
        text_rendering.should_receive(:push_text).with("  \tSome  text. \nSecond line.  \r  ")

        subject.render(text)
      end
    end

    context "for text with characters: ~`!@$%^&*()_+-='\";:,.?/{}[]|\#" do
      let(:text) { "~`!@$%^&*()_+-='\";:,.?/{}[]|\#" }

      it "should push one text chunk to text_rendering object" do
        text_rendering.should_receive(:push_text).with("~`!@$%^&*()_+-='\";:,.?/{}[]|\#" )

        subject.render(text)
      end
    end

    context "for text with tags surrounded by whitespaces" do
      let(:text) { "Outside <tag> inside text </tag> outside." }

      it "should push proper text and tag chunks" do
        text_rendering.should_receive(:push_text       ).with("Outside "     ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag"          ).ordered
        text_rendering.should_receive(:push_text       ).with(" inside text ").ordered
        text_rendering.should_receive(:push_closing_tag).with("tag"          ).ordered
        text_rendering.should_receive(:push_text       ).with(" outside."    ).ordered

        subject.render(text)
      end
    end

    context "for text with tags surrounded immediately by text" do
      let(:text) { "Outside<tag>inside</tag>outside." }

      it "should push proper text and tag chunks" do
        text_rendering.should_receive(:push_text       ).with("Outside" ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag"     ).ordered
        text_rendering.should_receive(:push_text       ).with("inside"  ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag"     ).ordered
        text_rendering.should_receive(:push_text       ).with("outside.").ordered

        subject.render(text)
      end
    end

    context "for text that starts and ends with tags" do
      let(:text) { "<tag>inside</tag>" }

      it "should push proper text and tag chunks" do
        text_rendering.should_receive(:push_opening_tag).with("tag"      ).ordered
        text_rendering.should_receive(:push_text       ).with("inside"   ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag"      ).ordered

        subject.render(text)
      end
    end

    context "for text with tags of empty content" do
      let(:text) { "Outside <tag></tag> outside." }

      it "should push proper text and tag chunks" do
        text_rendering.should_receive(:push_text       ).with("Outside " ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag"      ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag"      ).ordered
        text_rendering.should_receive(:push_text       ).with(" outside.").ordered

        subject.render(text)
      end
    end

    context "for text with nested tags" do
      let(:text) { "Outside <tag1><tag2>inside</tag2>inside</tag1> outside." }

      it "should push proper text and tag chunks" do
        text_rendering.should_receive(:push_text       ).with("Outside " ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag1"     ).ordered
        text_rendering.should_receive(:push_opening_tag).with("tag2"     ).ordered
        text_rendering.should_receive(:push_text       ).with("inside"   ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag2"     ).ordered
        text_rendering.should_receive(:push_text       ).with("inside"   ).ordered
        text_rendering.should_receive(:push_closing_tag).with("tag1"     ).ordered
        text_rendering.should_receive(:push_text       ).with(" outside.").ordered

        subject.render(text)
      end
    end
  end

  describe ".chunks" do
    subject { described_class.chunks(text) }

    context "for '' (empty text)" do
      let(:text) { "" }
      it { should == [] }
    end

    context "for 'This is some text' (text without tags)" do
      let(:text) { "This is some text" }
      it { should == ["This is some text"] }
    end

    context "for '  \tSome  text. \nSecond line.  \r  ' (text with multiple spaces, \\t, \\n and \\r characters)" do
      let(:text) { "  \tSome  text. \nSecond line.  \r  " }
      it { should == ["  \tSome  text. \nSecond line.  \r  "] }
    end

    context "for text with characters: d~`!@$%^&*()_+-='\";:,.?/{}[]|\\#" do
      let(:text) { "~`!@$%^&*()_+-='\";:,.?/{}[]|\\#" }
      it { should == ["~`!@$%^&*()_+-='\";:,.?/{}[]|\\#"] }
    end

    context "for 'Outside <tag> inside text </tag> outside.' (tags surrounded by whitespaces)" do
      let(:text) { "Outside <tag> inside text </tag> outside." }
      it { should == ["Outside ", "<tag>", " inside text ", "</tag>", " outside."] }
    end

    context "for 'Outside<tag>inside</tag>outside.' (tags immediately surrounded by text)" do
      let(:text) { "Outside<tag>inside</tag>outside." }
      it { should == ["Outside", "<tag>", "inside", "</tag>", "outside."] }
    end

    context "for '<tag>inside</tag>' (text that starts and ends with tags)" do
      let(:text) { "<tag>inside</tag>" }
      it { should == ["<tag>", "inside", "</tag>"] }
    end

    context "for 'Outside <tag></tag> outside.' (tags of empty content)" do
      let(:text) { "Outside <tag></tag> outside." }
      it { should == ["Outside ", "<tag>", "</tag>", " outside."] }
    end

    context "for 'Outside <tag1><tag2>inside</tag2>inside</tag1> outside.' (nested tags)" do
      let(:text) { "Outside <tag1><tag2>inside</tag2>inside</tag1> outside." }
      it { should == ["Outside ", "<tag1>", "<tag2>", "inside", "</tag2>", "inside", "</tag1>", " outside."] }
    end
  end
end
