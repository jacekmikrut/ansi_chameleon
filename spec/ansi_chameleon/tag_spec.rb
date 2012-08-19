require "spec_helper"

describe AnsiChameleon::Tag do

  it { should respond_to(:name) }
  it { should respond_to(:name=) }
  it { should respond_to(:id) }
  it { should respond_to(:id=) }
  it { should respond_to(:class_names) }
  it { should respond_to(:class_names=) }
  it { should respond_to(:parent) }
  it { should respond_to(:parent=) }
  it { should respond_to(:original_string) }
  it { should_not respond_to(:original_string=) }

  describe "after initialization" do
    context "without parameters" do
      its(:name) { should be_nil }
      its(:id) { should be_nil }
      its(:class_names) { should == [] }
      its(:parent) { should be_nil }
      its(:original_string) { should be_nil }
    end

    context "with :name value given as string" do
      subject(:tag) { described_class.new(:name => "tag-name") }
      it("should have that value set as string") { tag.name.should == "tag-name" }
    end

    context "with :name value given as symbol" do
      subject(:tag) { described_class.new(:name => :"tag-name") }
      it("should have that value set as string") { tag.name.should == "tag-name" }
    end

    context "with :id value given as string" do
      subject(:tag) { described_class.new(:id => "tagId") }
      it("should have that value set as string") { tag.id.should == "tagId" }
    end

    context "with :id value given as symbol" do
      subject(:tag) { described_class.new(:id => :"tagId") }
      it("should have that value set as string") { tag.id.should == "tagId" }
    end

    context "with :class_names values given as strings" do
      subject(:tag) { described_class.new(:class_names => ["class_1", "class_2"]) }
      it("should have that values set as strings") { tag.class_names.should == ["class_1", "class_2"] }
    end

    context "with :class_names values given as symbols" do
      subject(:tag) { described_class.new(:class_names => [:"class_1", :"class_2"]) }
      it("should have that values set as strings") { tag.class_names.should == ["class_1", "class_2"] }
    end

    context "with :parent value" do
      subject(:tag) { described_class.new(:parent => parent) }
      let(:parent) { stub(:parent) }
      it("should have that value set") { tag.parent.should equal(parent) }
    end

    context "with :original_string value" do
      subject(:tag) { described_class.new(:original_string => original_string) }
      let(:original_string) { "<tag>" }
      it("should have that value set") { tag.original_string.should equal(original_string) }
    end
  end

  describe "#name=" do
    subject(:tag)

    context "when called with a string" do
      before { tag.name = "tag-name" }
      it("should store the value as string") { tag.name.should == "tag-name" }
    end

    context "when called with a symbol" do
      before { tag.name = :"tag-name" }
      it("should store the value as string") { tag.name.should == "tag-name" }
    end

  end

  describe "#id=" do
    subject(:tag)

    context "when called with a string" do
      before { tag.id = "tagId" }
      it("should store the value as string") { tag.id.should == "tagId" }
    end

    context "when called with a symbol" do
      before { tag.id = :"tagId" }
      it("should store the value as string") { tag.id.should == "tagId" }
    end

  end

  describe "#class_names=" do
    subject(:tag)

    context "when called with an array of strings" do
      before { tag.class_names = ["class_1", "class_2"] }
      it("should store the values as strings") { tag.class_names.should == ["class_1", "class_2"] }
    end

    context "when called with an array of symbols" do
      before { tag.class_names = [:"class_1", :"class_2"] }
      it("should store the values as strings") { tag.class_names.should == ["class_1", "class_2"] }
    end

  end

  describe "#==" do
    subject(:tag   ) { described_class.new(:name => "name", :id => "id", :class_names => ["first_class", "second_class"], :parent => parent) }
        let(:other ) { described_class.new(:name => "name", :id => "id", :class_names => ["first_class", "second_class"], :parent => parent) }
        let(:parent) { stub(:parent) }

    context "when tags have the same names, ids, class names and parents" do
      it { expect(tag == other).to be_true }
    end

    context "when tag names are different" do
      before { other.name = "different name" }
      it { expect(tag == other).to be_false }
    end

    context "when tag ids are different" do
      before { other.id = "differentId" }
      it { expect(tag == other).to be_false }
    end

    context "when class names are different" do
      before { other.class_names = ["second_class"] }
      it { expect(tag == other).to be_false }
    end

    context "when class names are the same but in different order" do
      before { other.class_names = ["second_class", "first_class"] }
      it { expect(tag == other).to be_true }
    end

    context "when tag parents are different" do
      before { other.parent = stub(:different_parent) }
      it { expect(tag == other).to be_false }
    end

    context "when compared to nil" do
      it { expect(tag == nil).to be_false }
    end
  end
end
