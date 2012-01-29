require "spec_helper"

describe AnsiChameleon::SequenceGenerator do

  describe ".effect_code" do

    describe "(:none)" do
      it { subject.effect_code(:none).should == 0 }
    end

    describe "('bright')" do
      it { subject.effect_code('bright').should == 1 }
    end

    describe "(:unknown_effect_name)" do
      it do
        lambda {
          subject.effect_code(:unknown_effect_name)
        }.should raise_error(AnsiChameleon::SequenceGenerator::UnknownEffectName, "Unknown effect name :unknown_effect_name")
      end
    end
  end

  describe ".foreground_color_code" do

    describe "(:green)" do
      it { subject.foreground_color_code(:green).should == 32 }
    end

    describe "('white')" do
      it { subject.foreground_color_code('white').should == 37 }
    end

    describe "('unknown_color_name')" do
      it do
        lambda {
          subject.foreground_color_code('unknown_color_name')
        }.should raise_error(AnsiChameleon::SequenceGenerator::UnknownColorName, 'Unknown foreground color name "unknown_color_name"')
      end
    end
  end

  describe ".background_color_code" do

    describe "('red')" do
      it { subject.background_color_code('red').should == 41 }
    end

    describe "(:yellow)" do
      it { subject.background_color_code(:yellow).should == 43 }
    end

    describe "(:unknown_color_name)" do
      it do
        lambda {
          subject.background_color_code(:unknown_color_name)
        }.should raise_error(AnsiChameleon::SequenceGenerator::UnknownColorName, "Unknown background color name :unknown_color_name")
      end
    end
  end

  describe ".generate" do

    describe "(:reset)" do
      it { subject.generate(:reset).should == "\033[0m" }
    end

    describe "(:bright, :black, 'magenta')" do
      it { subject.generate(:bright, :black, 'magenta').should == "\033[1;30;45m" }
    end

    describe "('none', 'red', :cyan)" do
      it { subject.generate('none', 'red', :cyan).should == "\033[0;31;46m" }
    end

    describe "('unknown_effect_name', :green, :white)" do
      it do
        lambda {
          subject.generate('unknown_effect_name', :green, :white)
        }.should raise_error(AnsiChameleon::SequenceGenerator::UnknownEffectName)
      end
    end

    describe "(:underline, :unknown_color_name, :white)" do
      it do
        lambda {
          subject.generate(:underline, :unknown_color_name, :white)
        }.should raise_error(AnsiChameleon::SequenceGenerator::UnknownColorName)
      end
    end

    describe "(:underline, :cyan, 'unknown_color_name')" do
      it do
        lambda {
          subject.generate(:underline, :cyan, 'unknown_color_name')
        }.should raise_error(AnsiChameleon::SequenceGenerator::UnknownColorName)
      end
    end
  end
end
