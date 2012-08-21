require "spec_helper"

describe AnsiChameleon::TextRendering do

  def sequence(effect_name, foreground_color_name=nil, background_color_name=nil)
    "[SEQUENCE:#{effect_name}:#{foreground_color_name}:#{background_color_name}]"
  end

  let(:style_sheet_handler) { stub(:style_sheet_handler, :value_for => nil) }
  subject { AnsiChameleon::TextRendering.new(style_sheet_handler) }

  before do
    AnsiChameleon::SequenceGenerator.stub(:generate) do |effect_name, foreground_color_name, background_color_name|
      sequence(effect_name, foreground_color_name, background_color_name)
    end
  end

  describe "#to_s" do

    it "should end with the :reset sequence" do
      subject.to_s.should be_end_with(sequence(:reset))
    end

    describe "when the style sheet handler doesn't have any default values" do

      it "should start with the sequence for #{AnsiChameleon::TextRendering::DEFAULT_STYLE.inspect} values" do
        effect_name           = AnsiChameleon::TextRendering::DEFAULT_STYLE[:effect_name]
        foreground_color_name = AnsiChameleon::TextRendering::DEFAULT_STYLE[:foreground_color_name]
        background_color_name = AnsiChameleon::TextRendering::DEFAULT_STYLE[:background_color_name]

        subject.to_s.should be_start_with(sequence(effect_name, foreground_color_name, background_color_name))
      end
    end

    describe "when the style sheet handler has some default values" do
      before do
        style_sheet_handler.stub(:value_for).with(nil, :effect_name          ).and_return(:bright)
        style_sheet_handler.stub(:value_for).with(nil, :background_color_name).and_return(:blue)
      end

      it "should start with the sequence for given default values and for missing ones should use #{AnsiChameleon::TextRendering::DEFAULT_STYLE.inspect}" do
        foreground_color_name = AnsiChameleon::TextRendering::DEFAULT_STYLE[:foreground_color_name]

        subject.to_s.should be_start_with(sequence(:bright, foreground_color_name, :blue))
      end
    end
  end

  describe "usage scenarios" do
    before do
      style_sheet_handler.stub(:value_for).with(nil, :effect_name          ).and_return(:default_effect)
      style_sheet_handler.stub(:value_for).with(nil, :foreground_color_name).and_return(:default_fg_color)
      style_sheet_handler.stub(:value_for).with(nil, :background_color_name).and_return(:default_bg_color)
    end

    describe "for nothing pushed" do
      it "should return rendered text" do
        subject.to_s.should ==
          "#{sequence(:default_effect, :default_fg_color, :default_bg_color)}" +
          "#{sequence(:reset)}"
      end
    end

    describe "for some text pushed" do
      before do
        subject.push_text("First sentence. ")
        subject.push_text("Second sentence.")
      end

      it "should return rendered text" do
        subject.to_s.should ==
          "#{sequence(:default_effect, :default_fg_color, :default_bg_color)}" +
          "First sentence. Second sentence." +
          "#{sequence(:reset)}"
      end
    end

    describe "for some text and non-nested tags pushed" do
      before do
        tag_a_opening.should_receive(:parent=).with(nil)
        tag_b_opening.should_receive(:parent=).with(nil)

        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :effect_name          ).and_return(nil            )
        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :foreground_color_name).and_return(:inherit       )
        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :background_color_name).and_return(:tag_a_bg_color)

        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :effect_name          ).and_return(:tag_b_effect  )
        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :foreground_color_name).and_return(:tag_b_fg_color)
        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :background_color_name).and_return(:tag_b_bg_color)

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

      it "should return rendered text" do
        subject.to_s.should ==
          "#{sequence(:default_effect, :default_fg_color, :default_bg_color)}" +
            "First sentence. " +

            "#{sequence(:default_effect, :default_fg_color, :tag_a_bg_color)}" +
              "Text in tag_a." +
            "#{sequence(:default_effect, :default_fg_color, :default_bg_color)}" +

            "#{sequence(:tag_b_effect, :tag_b_fg_color, :tag_b_bg_color)}" +
              "Text in tag_b." +
            "#{sequence(:default_effect, :default_fg_color, :default_bg_color)}" +

            " Second sentence." +
          "#{sequence(:reset)}"
      end
    end

    describe "for some text and nested tags pushed" do
      before do
        tag_a_opening.should_receive(:parent=).with(nil)
        tag_b_opening.should_receive(:parent=).with(tag_a_opening)

        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :effect_name          ).and_return(nil            )
        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :foreground_color_name).and_return(:tag_a_fg_color)
        style_sheet_handler.should_receive(:value_for).with(tag_a_opening, :background_color_name).and_return(:tag_a_bg_color)

        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :effect_name          ).and_return(:inherit       )
        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :foreground_color_name).and_return(:inherit       )
        style_sheet_handler.should_receive(:value_for).with(tag_b_opening, :background_color_name).and_return(:tag_b_bg_color)

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

      it "should return rendered text" do
        subject.to_s.should ==
          "#{sequence(:default_effect, :default_fg_color, :default_bg_color)}" +
            "First sentence. " +

            "#{sequence(:default_effect, :tag_a_fg_color, :tag_a_bg_color)}" +
              "Text in tag_a." +

              "#{sequence(:default_effect, :tag_a_fg_color, :tag_b_bg_color)}" +
                "Text in tag_b." +
              "#{sequence(:default_effect, :tag_a_fg_color, :tag_a_bg_color)}" +

            "#{sequence(:default_effect, :default_fg_color, :default_bg_color)}" +

            " Second sentence." +
          "#{sequence(:reset)}"
      end
    end
  end
end
