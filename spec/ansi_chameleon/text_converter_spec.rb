require "spec_helper"

describe AnsiChameleon::TextConverter do

  let(:style_sheet_handler) { stub(:style_sheet_handler, :tag_names => tag_names) }
  let(:tag_names) { [] }

  describe "each instance" do
    let(:style_sheet) { stub(:style_sheet) }
    let(:text_conversion) { stub(:text_conversion, :push_opening_tag => nil, :push_closing_tag => nil, :push_text => nil, :to_s => 'converted text') }

    it "should create AnsiChameleon::StyleSheetHandler instance and use it for all conversions" do
      AnsiChameleon::StyleSheetHandler.should_receive(:new).with(style_sheet, AnsiChameleon::StylePropertyNameTranslator).once.and_return(style_sheet_handler)
      AnsiChameleon::TextConversion.should_receive(:new).with(style_sheet_handler).twice.and_return(text_conversion)

      text_converter = AnsiChameleon::TextConverter.new(style_sheet)
      text_converter.convert('Some text')
      text_converter.convert('Some other text')
    end
  end

  describe "#convert" do
    before { AnsiChameleon::StyleSheetHandler.stub(:new => style_sheet_handler) }
    subject { AnsiChameleon::TextConverter.new(stub(:style_sheet)) }
    let(:converted_text) { stub(:converted_text) }

    describe "for empty text" do
      let(:text_conversion) { stub(:text_conversion) }
      it "should create AnsiChameleon::TextConversion and simply call #to_s" do
        AnsiChameleon::TextConversion.should_receive(:new).with(style_sheet_handler).and_return(text_conversion)
        text_conversion.should_receive(:to_s     ).ordered.and_return(converted_text)

        subject.convert("").should == converted_text
      end
    end

    describe "for a text with some tags" do
      let(:text_conversion) { stub(:text_conversion) }
      let(:tag_names) { [:first_tag, :second_tag, :third_tag] }

      it "should create AnsiChameleon::TextConversion instance and push tags and text chunks found in given text" do
        AnsiChameleon::TextConversion.should_receive(:new).with(style_sheet_handler).and_return(text_conversion)
        text_conversion.should_receive(:push_text       ).with("This"      ).ordered
        text_conversion.should_receive(:push_text       ).with(" "         ).ordered
        text_conversion.should_receive(:push_opening_tag).with(:first_tag  ).ordered
        text_conversion.should_receive(:push_text       ).with("is"        ).ordered
        text_conversion.should_receive(:push_text       ).with(" "         ).ordered
        text_conversion.should_receive(:push_opening_tag).with(:second_tag ).ordered
        text_conversion.should_receive(:push_text       ).with("an"        ).ordered
        text_conversion.should_receive(:push_closing_tag).with(:second_tag ).ordered
        text_conversion.should_receive(:push_text       ).with(" "         ).ordered
        text_conversion.should_receive(:push_text       ).with("example"   ).ordered
        text_conversion.should_receive(:push_closing_tag).with(:first_tag  ).ordered
        text_conversion.should_receive(:push_opening_tag).with(:third_tag  ).ordered
        text_conversion.should_receive(:push_text       ).with(" "         ).ordered
        text_conversion.should_receive(:push_text       ).with("text."     ).ordered
        text_conversion.should_receive(:push_closing_tag).with(:third_tag  ).ordered
        text_conversion.should_receive(:to_s            ).ordered.and_return(converted_text)

        subject.convert("This <first_tag>is <second_tag>an</second_tag> example</first_tag><third_tag> text.</third_tag>").should == converted_text
      end
    end

    describe "for a text that contains tags not recognized by the style_sheet_handler" do
      let(:text_conversion) { stub(:text_conversion) }
      let(:tag_names) { [] }

      it "should create AnsiChameleon::TextConversion instance and push unknown tags as normal text" do
        AnsiChameleon::TextConversion.should_receive(:new).with(style_sheet_handler).and_return(text_conversion)
        text_conversion.should_receive(:push_text).with("This"                ).ordered
        text_conversion.should_receive(:push_text).with(" "                   ).ordered
        text_conversion.should_receive(:push_text).with("<unknown_tag>"       ).ordered
        text_conversion.should_receive(:push_text).with(" "                   ).ordered
        text_conversion.should_receive(:push_text).with("is"                  ).ordered
        text_conversion.should_receive(:push_text).with(" "                   ).ordered
        text_conversion.should_receive(:push_text).with("a</unknown_tag>text.").ordered
        text_conversion.should_receive(:to_s     ).ordered.and_return(converted_text)

        subject.convert("This <unknown_tag> is a</unknown_tag>text.").should == converted_text
      end
    end
  end
end
