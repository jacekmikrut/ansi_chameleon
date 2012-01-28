require "spec_helper"

describe AnsiChameleon::StyleSheetHandler do

  STYLE_SHEET_0 = {}

  context "for style sheet: #{STYLE_SHEET_0}" do
    subject { AnsiChameleon::StyleSheetHandler.new(STYLE_SHEET_0) }

    its(:default_values) { should == {} }
    its(:tag_names) { should == [] }

    describe "value_for(:unknown_property)" do
      it { subject.value_for(:unknown_property).should be_nil }
    end

    describe "value_for(:unknown_tag, :unknown_property)" do
      it { subject.value_for(:unknown_tag, :unknown_property).should be_nil }
    end
  end

  STYLE_SHEET_1 = {
    :property => :default_value,

    :tag => {
      :property => :value_in_tag
    }
  }

  context "for style sheet: #{STYLE_SHEET_1}" do
    subject { AnsiChameleon::StyleSheetHandler.new(STYLE_SHEET_1) }

    its(:default_values) { should == { :property => :default_value } }
    its(:tag_names) { should == [:tag] }

    describe "value_for(:property)" do
      it { subject.value_for(:property).should == :default_value }
    end

    describe "value_for(:unknown_property)" do
      it { subject.value_for(:unknown_property).should be_nil }
    end

    describe "value_for(:tag, :property)" do
      it { subject.value_for(:tag, :property).should == :value_in_tag }
    end

    describe "value_for(:tag, :unknown_property)" do
      it { subject.value_for(:tag, :unknown_property).should be_nil }
    end

    describe "value_for(:unknown_tag, :property)" do
      it { subject.value_for(:unknown_tag, :property).should == :default_value }
    end

    describe "value_for(:tag, :unknown_tag, :property)" do
      it { subject.value_for(:tag, :unknown_tag, :property).should == :value_in_tag }
    end

    describe "value_for(:unknown_tag, :tag, :property)" do
      it { subject.value_for(:unknown_tag, :tag, :property).should == :value_in_tag }
    end
  end

  STYLE_SHEET_1s = {
    'property' => 'default_value',

    'tag' => {
      'property' => 'value_in_tag'
    }
  }

  context "for style sheet: #{STYLE_SHEET_1s}" do
    subject { AnsiChameleon::StyleSheetHandler.new(STYLE_SHEET_1s) }

    its(:default_values) { should == { :property => 'default_value' } }
    its(:tag_names) { should == [:tag] }

    describe "value_for(:property)" do
      it { subject.value_for(:property).should == 'default_value' }
    end

    describe "value_for('property')" do
      it { subject.value_for('property').should == 'default_value' }
    end

    describe "value_for(:tag, :property)" do
      it { subject.value_for(:tag, :property).should == 'value_in_tag' }
    end

    describe "value_for('tag', :property)" do
      it { subject.value_for('tag', :property).should == 'value_in_tag' }
    end
  end

  STYLE_SHEET_2 = {
    :property => :default_value,

    :tag_a => {
      :property => :value_in_tag_a,
    },

    :tag_b => {
      :property => :value_in_tag_b,
    }
  }

  context "for style sheet: #{STYLE_SHEET_2}" do
    subject { AnsiChameleon::StyleSheetHandler.new(STYLE_SHEET_2) }

    its(:default_values) { should == { :property => :default_value } }
    its(:tag_names) { should == [:tag_a, :tag_b] }

    describe "value_for(:tag_a, :property)" do
      it { subject.value_for(:tag_a, :property).should == :value_in_tag_a }
    end

    describe "value_for(:tag_b, :property)" do
      it { subject.value_for(:tag_b, :property).should == :value_in_tag_b }
    end

    describe "value_for(:tag_a, :tag_b, :property)" do
      it { subject.value_for(:tag_a, :tag_b, :property).should == :value_in_tag_b }
    end

    describe "value_for(:tag_b, :tag_a, :property)" do
      it { subject.value_for(:tag_b, :tag_a, :property).should == :value_in_tag_a }
    end
  end

  STYLE_SHEET_3 = {
    :property => :default_value,

    :tag_a => {
      :property => :value_in_tag_a
    },

    :tag_b => {
      :tag_a => {
        :property => :value_in_tag_a_in_tag_b
      }
    }
  }

  context "for style sheet: #{STYLE_SHEET_3}" do
    subject { AnsiChameleon::StyleSheetHandler.new(STYLE_SHEET_3) }

    its(:default_values) { should == { :property => :default_value } }
    its(:tag_names) { should == [:tag_a, :tag_b] }

    describe "value_for(:tag_a, :property)" do
      it { subject.value_for(:tag_a, :property).should == :value_in_tag_a }
    end

    describe "value_for(:tag_b, :property)" do
      it { subject.value_for(:tag_b, :property).should == :default_value }
    end

    describe "value_for(:tag_a, :tag_b, :property)" do
      it { subject.value_for(:tag_a, :tag_b, :property).should == :value_in_tag_a }
    end

    describe "value_for(:tag_b, :tag_a, :property)" do
      it { subject.value_for(:tag_b, :tag_a, :property).should == :value_in_tag_a_in_tag_b }
    end
  end
end
