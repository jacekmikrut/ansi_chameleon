require "spec_helper"

describe AnsiChameleon::StylePropertyNameTranslator do

  describe ".translate(:background_color)" do
    it { subject.translate(:background_color).should == :background_color }
  end

  describe ".translate(:background)" do
    it { subject.translate(:background).should       == :background_color }
  end

  describe ".translate(:bg_color)" do
    it { subject.translate(:bg_color).should         == :background_color }
  end

  describe ".translate(:foreground_color)" do
    it { subject.translate(:foreground_color).should == :foreground_color }
  end

  describe ".translate(:foreground)" do
    it { subject.translate(:foreground).should       == :foreground_color }
  end

  describe ".translate(:fg_color)" do
    it { subject.translate(:fg_color).should         == :foreground_color }
  end

  describe ".translate(:effect)" do
    it { subject.translate(:effect).should           == :effect }
  end
end
