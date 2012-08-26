require "spec_helper"

describe AnsiChameleon::SequenceGenerator do

  subject { eval(example.example_group.example.example_group.description) }

  describe ".bold_text_sequence" do

    describe "AnsiChameleon::SequenceGenerator.bold_text_sequence(true)" do
      it { should == "\033[1m" }
    end

    describe "AnsiChameleon::SequenceGenerator.bold_text_sequence(:invalid_effect_value)" do
      it do
        lambda {
          subject
        }.should raise_error(AnsiChameleon::SequenceGenerator::InvalidEffectValueError, "Invalid effect value :invalid_effect_value")
      end
    end
  end

  describe ".underlined_text_sequence" do

    describe "AnsiChameleon::SequenceGenerator.underlined_text_sequence(:yes)" do
      it { should == "\033[4m" }
    end

    describe "AnsiChameleon::SequenceGenerator.underlined_text_sequence(:invalid_effect_value)" do
      it do
        lambda {
          subject
        }.should raise_error(AnsiChameleon::SequenceGenerator::InvalidEffectValueError, "Invalid effect value :invalid_effect_value")
      end
    end
  end

  describe ".blinking_text_sequence" do

    describe "AnsiChameleon::SequenceGenerator.blinking_text_sequence(:on)" do
      it { should == "\033[5m" }
    end

    describe "AnsiChameleon::SequenceGenerator.blinking_text_sequence(:invalid_effect_value)" do
      it do
        lambda {
          subject
        }.should raise_error(AnsiChameleon::SequenceGenerator::InvalidEffectValueError, "Invalid effect value :invalid_effect_value")
      end
    end
  end

  describe ".reverse_video_text_sequence" do

    describe "AnsiChameleon::SequenceGenerator.reverse_video_text_sequence(true)" do
      it { should == "\033[7m" }
    end

    describe "AnsiChameleon::SequenceGenerator.reverse_video_text_sequence(:invalid_effect_value)" do
      it do
        lambda {
          subject
        }.should raise_error(AnsiChameleon::SequenceGenerator::InvalidEffectValueError, "Invalid effect value :invalid_effect_value")
      end
    end
  end

  describe ".foreground_color_sequence" do

    describe "AnsiChameleon::SequenceGenerator.foreground_color_sequence(:green)" do
      it { should == "\033[32m" }
    end

    describe "AnsiChameleon::SequenceGenerator.foreground_color_sequence('white')" do
      it { should == "\033[37m" }
    end

    describe "AnsiChameleon::SequenceGenerator.foreground_color_sequence('57')" do
      it { should == "\033[38;5;57m" }
    end

    describe "AnsiChameleon::SequenceGenerator.foreground_color_sequence(190)" do
      it { should == "\033[38;5;190m" }
    end

    describe "AnsiChameleon::SequenceGenerator.foreground_color_sequence(256)" do
      it do
        lambda {
          subject
        }.should raise_error(AnsiChameleon::SequenceGenerator::InvalidColorValueError, 'Invalid foreground color value 256')
      end
    end

    describe "AnsiChameleon::SequenceGenerator.foreground_color_sequence('invalid_color_value')" do
      it do
        lambda {
          subject
        }.should raise_error(AnsiChameleon::SequenceGenerator::InvalidColorValueError, 'Invalid foreground color value "invalid_color_value"')
      end
    end
  end

  describe ".background_color_sequence" do

    describe "AnsiChameleon::SequenceGenerator.background_color_sequence('red')" do
      it { should == "\033[41m" }
    end

    describe "AnsiChameleon::SequenceGenerator.background_color_sequence(:yellow)" do
      it { should == "\033[43m" }
    end

    describe "AnsiChameleon::SequenceGenerator.background_color_sequence('255')" do
      it { should == "\033[48;5;255m" }
    end

    describe "AnsiChameleon::SequenceGenerator.background_color_sequence(2)" do
      it { should == "\033[48;5;2m" }
    end

    describe "AnsiChameleon::SequenceGenerator.background_color_sequence('256')" do
      it do
        lambda {
          subject
        }.should raise_error(AnsiChameleon::SequenceGenerator::InvalidColorValueError, "Invalid background color value \"256\"")
      end
    end

    describe "AnsiChameleon::SequenceGenerator.background_color_sequence(:invalid_color_value)" do
      it do
        lambda {
          subject
        }.should raise_error(AnsiChameleon::SequenceGenerator::InvalidColorValueError, "Invalid background color value :invalid_color_value")
      end
    end
  end

  describe ".generate" do

    describe "AnsiChameleon::SequenceGenerator.generate(:bold_text => :bold_text_value, :underlined_text => :underlined_text_value)" do
      it "should only generate sequences for given properties" do
        AnsiChameleon::SequenceGenerator.should_receive(         :bold_text_sequence).with(      :bold_text_value).and_return(      '[bold_text_sequence]')
        AnsiChameleon::SequenceGenerator.should_receive(   :underlined_text_sequence).with(:underlined_text_value).and_return('[underlined_text_sequence]')
        AnsiChameleon::SequenceGenerator.should_not_receive(     :blinking_text_sequence)
        AnsiChameleon::SequenceGenerator.should_not_receive(:reverse_video_text_sequence)
        AnsiChameleon::SequenceGenerator.should_not_receive(  :foreground_color_sequence)
        AnsiChameleon::SequenceGenerator.should_not_receive(  :background_color_sequence)

        subject.should == "\033[0m[bold_text_sequence][underlined_text_sequence]"
      end
    end

    describe "AnsiChameleon::SequenceGenerator.generate(:blinking_text => :blinking_text_value, :reverse_video_text => :reverse_video_text_value)" do
      it "should only generate sequences for given properties" do
        AnsiChameleon::SequenceGenerator.should_not_receive(         :bold_text_sequence)
        AnsiChameleon::SequenceGenerator.should_not_receive(   :underlined_text_sequence)
        AnsiChameleon::SequenceGenerator.should_receive(         :blinking_text_sequence).with(     :blinking_text_value).and_return(     '[blinking_text_sequence]')
        AnsiChameleon::SequenceGenerator.should_receive(    :reverse_video_text_sequence).with(:reverse_video_text_value).and_return('[reverse_video_text_sequence]')
        AnsiChameleon::SequenceGenerator.should_not_receive(  :foreground_color_sequence)
        AnsiChameleon::SequenceGenerator.should_not_receive(  :background_color_sequence)

        subject.should == "\033[0m[blinking_text_sequence][reverse_video_text_sequence]"
      end
    end

    describe "AnsiChameleon::SequenceGenerator.generate(:foreground_color => :foreground_color_value, :background_color => :background_color_value)" do
      it "should only generate sequences for given properties" do
        AnsiChameleon::SequenceGenerator.should_not_receive(         :bold_text_sequence)
        AnsiChameleon::SequenceGenerator.should_not_receive(   :underlined_text_sequence)
        AnsiChameleon::SequenceGenerator.should_not_receive(     :blinking_text_sequence)
        AnsiChameleon::SequenceGenerator.should_not_receive(:reverse_video_text_sequence)
        AnsiChameleon::SequenceGenerator.should_receive(      :foreground_color_sequence).with(:foreground_color_value).and_return('[foreground_color_sequence]')
        AnsiChameleon::SequenceGenerator.should_receive(      :background_color_sequence).with(:background_color_value).and_return('[background_color_sequence]')

        subject.should == "\033[0m[foreground_color_sequence][background_color_sequence]"
      end
    end
  end
end
