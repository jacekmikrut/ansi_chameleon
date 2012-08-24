require "spec_helper"

describe AnsiChameleon::TextRenderer do

  let(:style_sheet_handler) { stub(:style_sheet_handler) }

  describe "each instance" do
    let(:style_sheet) { stub(:style_sheet) }
    let(:text_rendering) { stub(:text_rendering, :push_opening_tag => nil, :push_closing_tag => nil, :push_text => nil, :to_s => 'rendered text') }

    it "should create SimpleStyleSheet::Handler instance and use it for all renderings" do
      SimpleStyleSheet::Handler.should_receive(:new).with(style_sheet, AnsiChameleon::StylePropertyNameTranslator).once.and_return(style_sheet_handler)
      AnsiChameleon::TextRendering.should_receive(:new).with(style_sheet_handler).twice.and_return(text_rendering)

      text_renderer = AnsiChameleon::TextRenderer.new(style_sheet)
      text_renderer.render('Some text')
      text_renderer.render('Some other text')
    end
  end

  describe "#render" do
    before { SimpleStyleSheet::Handler.stub(:new => style_sheet_handler) }
    subject { described_class.new(stub(:style_sheet)) }
    before { AnsiChameleon::TextRendering.stub(:new => text_rendering) }
    let(:text_rendering) { stub(:text_rendering, :to_s => rendered_text) }
    before { described_class.stub(:chunks => []) }
    let(:rendered_text) { stub(:rendered_text) }
    let(:text) { stub(:text) }

    it "should create AnsiChameleon::TextRendering with the style sheet handler for every call" do
      AnsiChameleon::TextRendering.should_receive(:new).with(style_sheet_handler).exactly(3).times.and_return(text_rendering)
      subject.render(text)
      subject.render(text)
      subject.render(text)
    end

    it "should call AnsiChameleon::TextRenderer.chunks to get the chunks" do
      described_class.should_receive(:chunks).with(text).and_return([])
      subject.render(text)
    end

    it "should call proper text_rendering methods for each chunk" do
      described_class.stub(:chunks => ["text1", "<tag>", "text2", "</tag>"])
      AnsiChameleon::Tag.stub(:parse).with("text1" ).and_return(nil)
      AnsiChameleon::Tag.stub(:parse).with("<tag>" ).and_return(opening_tag = stub(:opening_tag, :name => "tag", :opening? => true))
      AnsiChameleon::Tag.stub(:parse).with("text2" ).and_return(nil)
      AnsiChameleon::Tag.stub(:parse).with("</tag>").and_return(closing_tag = stub(:closing_tag, :name => "tag", :opening? => false))

      text_rendering.should_receive(:push_text       ).with("text1").once.ordered
      text_rendering.should_receive(:push_opening_tag).with(opening_tag).once.ordered
      text_rendering.should_receive(:push_text       ).with("text2").once.ordered
      text_rendering.should_receive(:push_closing_tag).with(closing_tag).once.ordered

      subject.render(text)
    end

    it "should return the value obtained from the text_rendering#to_s" do
      text_rendering.should_receive(:to_s).once.and_return(rendered_text)
      subject.render(text).should == rendered_text
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
