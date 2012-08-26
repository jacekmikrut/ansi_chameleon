require "spec_helper"

describe AnsiChameleon::TextRendering do

  def sequence(style)
    "[SEQUENCE:RESET:" + style.map { |key, value| "#{key}=#{value}" }.join(":") + "]"
  end

  let(:style_sheet_handler) { stub(:style_sheet_handler, :value_for => nil) }
  subject { AnsiChameleon::TextRendering.new(style_sheet_handler) }

  before do
    AnsiChameleon::SequenceGenerator.stub(:generate) { |style| sequence(style) }
  end

  describe "#to_s" do

    describe "when the style sheet handler doesn't have any default values" do
      context "when there is some text pushed" do
        before { subject.push_text("Some text.") }

        it "should return the pushed text" do
          expect(subject.to_s).to eq("Some text.")
        end
      end

      context "when no text nor tags were pushed" do
        it "should return an empty string" do
          expect(subject.to_s).to eq("")
        end
      end
    end

    describe "when the style sheet handler has some default values" do
      before do
        style_sheet_handler.stub(:value_for).with(nil, :bold_text       ).and_return(:on)
        style_sheet_handler.stub(:value_for).with(nil, :background_color).and_return(:blue)
      end

      context "when there is some text pushed" do
        before { subject.push_text("Some text.") }

        it "should start with the sequence for given default values" do
          expect(subject.to_s).to start_with(sequence(:bold_text => :on, :background_color => :blue))
        end
      end

      context "when no text nor tags were pushed" do
        it "should start with the sequence for given default values" do
          expect(subject.to_s).to start_with(sequence(:bold_text => :on, :background_color => :blue))
        end
      end
    end
  end

  describe "usage scenarios" do
    before do
      style_sheet_handler.stub(:value_for).with(nil, :bold_text         ).and_return(:default_bold_text)
      style_sheet_handler.stub(:value_for).with(nil, :foreground_color  ).and_return(:default_fg_color)
      style_sheet_handler.stub(:value_for).with(nil, :background_color  ).and_return(:default_bg_color)
    end

    describe "for nothing pushed" do
      it "should return rendered text" do
        subject.to_s.should ==
          "#{sequence(:bold_text => :default_bold_text, :foreground_color => :default_fg_color, :background_color => :default_bg_color)}" +
          "#{sequence({})}"
      end
    end

    describe "for some text pushed" do
      before do
        subject.push_text("First sentence. ")
        subject.push_text("Second sentence.")
      end

      it "should return rendered text" do
        subject.to_s.should ==
          "#{sequence(:bold_text => :default_bold_text, :foreground_color => :default_fg_color, :background_color => :default_bg_color)}" +
          "First sentence. Second sentence." +
          "#{sequence({})}"
      end
    end

    describe "for some text and non-nested tags pushed" do
      before do
        tag_a_opening.should_receive(:parent=).with(nil)
        tag_b_opening.should_receive(:parent=).with(nil)

        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :bold_text       ).and_return(nil                   )
        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :foreground_color).and_return(tag_a_foreground_color)
        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :background_color).and_return(tag_a_background_color)

        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :bold_text       ).and_return(tag_b_bold_text       )
        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :foreground_color).and_return(tag_b_foreground_color)
        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :background_color).and_return(tag_b_background_color)

        subject.push_text("First sentence. ")

        subject.push_opening_tag(tag_a_opening)
          subject.push_text("Text in tag_a.")
        subject.push_closing_tag(tag_a_closing)

        subject.push_opening_tag(tag_b_opening)
          subject.push_text("Text in ")
          subject.push_text("tag_b.")
        subject.push_closing_tag(tag_b_closing)

        subject.push_text(" Second sentence.")
      end

      let(:tag_a_opening) { stub(:tag_a_opening, :name => "tag_a") }
      let(:tag_a_closing) { stub(:tag_a_closing, :name => "tag_a") }
      let(:tag_b_opening) { stub(:tag_b_opening, :name => "tag_b") }
      let(:tag_b_closing) { stub(:tag_b_closing, :name => "tag_b") }

      shared_examples_for "some text and non-nested tags" do
        it "should return rendered text" do
          subject.to_s.should ==
            "#{sequence(:bold_text => :default_bold_text, :foreground_color => :default_fg_color, :background_color => :default_bg_color)}" +
              "First sentence. " +

              "#{sequence(:foreground_color => :default_fg_color, :background_color => :tag_a_bg_color)}" +
                "Text in tag_a." +
              "#{sequence(:bold_text => :default_bold_text, :foreground_color => :default_fg_color, :background_color => :default_bg_color)}" +

              "#{sequence(:bold_text => :tag_b_bold_text, :foreground_color => :tag_b_fg_color, :background_color => :tag_b_bg_color)}" +
                "Text in tag_b." +
              "#{sequence(:bold_text => :default_bold_text, :foreground_color => :default_fg_color, :background_color => :default_bg_color)}" +

              " Second sentence." +
            "#{sequence({})}"
        end
      end

      context "when property values are given as Symbols" do
        let(:tag_a_foreground_color) { :inherit        }
        let(:tag_a_background_color) { :tag_a_bg_color }

        let(:tag_b_bold_text       ) { :tag_b_bold_text }
        let(:tag_b_foreground_color) { :tag_b_fg_color }
        let(:tag_b_background_color) { :tag_b_bg_color }

        include_examples "some text and non-nested tags"
      end

      context "when property values are given as Strings" do
        let(:tag_a_foreground_color) { "inherit"        }
        let(:tag_a_background_color) { "tag_a_bg_color" }

        let(:tag_b_bold_text       ) { "tag_b_bold_text" }
        let(:tag_b_foreground_color) { "tag_b_fg_color" }
        let(:tag_b_background_color) { "tag_b_bg_color" }

        include_examples "some text and non-nested tags"
      end
    end

    describe "for some text and nested tags pushed" do
      before do
        tag_a_opening.should_receive(:parent=).with(nil)
        tag_b_opening.should_receive(:parent=).with(tag_a_opening)

        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :bold_text       ).and_return(nil                   )
        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :foreground_color).and_return(tag_a_foreground_color)
        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :background_color).and_return(tag_a_background_color)

        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :bold_text       ).and_return(tag_b_bold_text       )
        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :foreground_color).and_return(nil                   )
        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :background_color).and_return(tag_b_background_color)

        subject.push_text("First sentence. ")

        subject.push_opening_tag(tag_a_opening)
          subject.push_text("Text in tag_a.")

          subject.push_opening_tag(tag_b_opening)
            subject.push_text("Text in ")
            subject.push_text("tag_b.")
          subject.push_closing_tag(tag_b_closing)

        subject.push_closing_tag(tag_a_closing)

        subject.push_text(" Second sentence.")
      end

      let(:tag_a_opening) { stub(:tag_a_opening, :name => "tag_a") }
      let(:tag_a_closing) { stub(:tag_a_closing, :name => "tag_a") }
      let(:tag_b_opening) { stub(:tag_b_opening, :name => "tag_b") }
      let(:tag_b_closing) { stub(:tag_b_closing, :name => "tag_b") }

      shared_examples_for "some text and nested tags" do
        it "should return rendered text" do
          subject.to_s.should ==
            "#{sequence(:bold_text => :default_bold_text, :foreground_color => :default_fg_color, :background_color => :default_bg_color)}" +
              "First sentence. " +

              "#{sequence(:foreground_color => :tag_a_fg_color, :background_color => :tag_a_bg_color)}" +
                "Text in tag_a." +

                "#{sequence(:background_color => :tag_b_bg_color)}" +
                  "Text in tag_b." +
                "#{sequence(:foreground_color => :tag_a_fg_color, :background_color => :tag_a_bg_color)}" +

              "#{sequence(:bold_text => :default_bold_text, :foreground_color => :default_fg_color, :background_color => :default_bg_color)}" +

              " Second sentence." +
            "#{sequence({})}"
        end
      end

      context "when property values are given as Symbols" do
        let(:tag_a_foreground_color) { :tag_a_fg_color }
        let(:tag_a_background_color) { :tag_a_bg_color }

        let(:tag_b_bold_text       ) { :inherit        }
        let(:tag_b_background_color) { :tag_b_bg_color }

        include_examples "some text and nested tags"
      end

      context "when property values are given as Strings" do
        let(:tag_a_foreground_color) { "tag_a_fg_color" }
        let(:tag_a_background_color) { "tag_a_bg_color" }

        let(:tag_b_bold_text       ) { "inherit"        }
        let(:tag_b_background_color) { "tag_b_bg_color" }

        include_examples "some text and nested tags"
      end
    end
  end
end
