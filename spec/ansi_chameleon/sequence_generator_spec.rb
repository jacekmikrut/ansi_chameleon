require "spec_helper"

describe AnsiChameleon::SequenceGenerator do

  subject { eval(example.example_group.example.example_group.description) }

  describe ".effect_sequence" do

    describe "AnsiChameleon::SequenceGenerator.effect_sequence(:none)" do
      it { should == "\033[0m" }
    end

    describe "AnsiChameleon::SequenceGenerator.effect_sequence(:bright)" do
      it { should == "\033[1m" }
    end

    describe "AnsiChameleon::SequenceGenerator.effect_sequence(:invalid_effect_value)" do
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

    describe "AnsiChameleon::SequenceGenerator.generate(:reset)" do
      it { should == "\033[0m" }
    end

    describe "AnsiChameleon::SequenceGenerator.generate(:effect_value, :foreground_color_value, :background_color_value)" do
      it "should delegate sequences generation to proper methods and return received sequences concatenated in proper order" do
        AnsiChameleon::SequenceGenerator.should_receive(:effect_sequence          ).with(:effect_value          ).ordered.and_return('[effect_sequence]'          )
        AnsiChameleon::SequenceGenerator.should_receive(:foreground_color_sequence).with(:foreground_color_value).ordered.and_return('[foreground_color_sequence]')
        AnsiChameleon::SequenceGenerator.should_receive(:background_color_sequence).with(:background_color_value).ordered.and_return('[background_color_sequence]')

        subject.should == "\033[0m[effect_sequence][foreground_color_sequence][background_color_sequence]"
      end
    end
  end
end
