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

  STYLE_SHEET_FOR_TRANSLATOR = {
    :property_1 => :some_value_1,

    :tag => {
      :property_1 => :some_value_2,
      :property_2 => :some_value_3
    }
  }

  describe "when initialized with property_name_translator" do
    subject { AnsiChameleon::StyleSheetHandler.new(STYLE_SHEET_FOR_TRANSLATOR, property_name_translator) }
    let(:property_name_translator) { stub(:property_name_translator) }

    it "should ask the translator to translate each property name found in the style sheet" do
      property_name_translator.should_receive(:translate).with(:property_1).twice.and_return(:property_1_translated)
      property_name_translator.should_receive(:translate).with(:property_2).once.and_return(:property_2_translated)
      subject
    end

    it "should use translated property names" do
      property_name_translator.stub(:translate).with(:property_1).and_return(:property_1_translated)
      property_name_translator.stub(:translate).with(:property_2).and_return(:property_2_translated)

      subject.value_for(      :property_1_translated).should == :some_value_1
      subject.value_for(:tag, :property_1_translated).should == :some_value_2
      subject.value_for(:tag, :property_2_translated).should == :some_value_3
    end

    it "should not use property names defined in the style sheet" do
      property_name_translator.stub(:translate).with(:property_1).and_return(:property_1_translated)
      property_name_translator.stub(:translate).with(:property_2).and_return(:property_2_translated)

      subject.value_for(      :property_1).should be_nil
      subject.value_for(:tag, :property_1).should be_nil
      subject.value_for(:tag, :property_2).should be_nil
    end
  end
end
