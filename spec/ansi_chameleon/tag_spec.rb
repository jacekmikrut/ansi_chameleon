require "spec_helper"

describe AnsiChameleon::Tag do

  it { should respond_to(:closing=) }
  it { should respond_to(:closing?) }
  it { should respond_to(:opening?) }
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
      its(:closing?       ) { should be_false }
      its(:opening?       ) { should be_true }
      its(:name           ) { should be_nil }
      its(:id             ) { should be_nil }
      its(:class_names    ) { should == []  }
      its(:parent         ) { should be_nil }
      its(:original_string) { should be_nil }
    end

    context "with :closing value given" do
      it "should use #closing= to assign it" do
        described_class.any_instance.should_receive(:closing=).with(true).once
        described_class.new(:closing => true)
      end
    end

    context "with :name value given" do
      it "should use #name= to assign it" do
        described_class.any_instance.should_receive(:name=).with("tag-name").once
        described_class.new(:name => "tag-name")
      end
    end

    context "with :id value given" do
      it "should use #id= to assign it" do
        described_class.any_instance.should_receive(:id=).with("tagId").once
        described_class.new(:id => "tagId")
      end
    end

    context "with :class_names value given" do
      it "should use #class_names= to assign it" do
        described_class.any_instance.should_receive(:class_names=).with(["class_1", "class_2"]).once
        described_class.new(:class_names => ["class_1", "class_2"])
      end
    end

    context "with :parent value given" do
      let(:parent) { stub(:parent) }

      it "should use #parent= to assign it" do
        described_class.any_instance.should_receive(:parent=).with(parent).once
        described_class.new(:parent => parent)
      end
    end

    context "with :original_string value given" do
      it "should use #original_string= to assign it" do
        described_class.any_instance.should_receive(:original_string=).with("<tag>").once
        described_class.new(:original_string => "<tag>")
      end
    end
  end

  describe "#closing=" do
    subject(:tag)

    context "when set to true" do
      before { tag.closing = true }

      describe "#closing?" do
        it { tag.closing?.should be_true }
      end

      describe "#opening?" do
        it { tag.opening?.should be_false }
      end
    end

    context "when set to false" do
      before { tag.closing = false }

      describe "#closing?" do
        it { tag.closing?.should be_false }
      end

      describe "#opening?" do
        it { tag.opening?.should be_true }
      end
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

  describe ".parse" do
    subject { described_class.parse(string) }

    context "for '' (empty string)" do
      let(:string) { "" }
      it { should be_nil }
    end

    context "for '  ' (blank string)" do
      let(:string) { "  " }
      it { should be_nil }
    end

    context "for 'An ordinary text.'" do
      let(:string) { "An ordinary text." }
      it { should be_nil }
    end

    context "for '/abc'" do
      let(:string) { "/abc" }
      it { should be_nil }
    end

    context "for '<2abc>'" do
      let(:string) { "<2abc>" }
      it { should be_nil }
    end

    context "for '</2abc>'" do
      let(:string) { "</2abc>" }
      it { should be_nil }
    end

    context "for '<//abc>'" do
      let(:string) { "<//abc>" }
      it { should be_nil }
    end

    context "for '< abc>'" do
      let(:string) { "< abc>" }
      it { should be_nil }
    end

    context "for '</ abc>'" do
      let(:string) { "</ abc>" }
      it { should be_nil }
    end

    context "for '<abc'" do
      let(:string) { "<abc" }
      it { should be_nil }
    end

    context "for '</abc'" do
      let(:string) { "</abc" }
      it { should be_nil }
    end

    context "for 'abc>'" do
      let(:string) { "abc>" }
      it { should be_nil }
    end

    context "for '<'" do
      let(:string) { "<" }
      it { should be_nil }
    end

    context "for '>'" do
      let(:string) { ">" }
      it { should be_nil }
    end

    context "for an opening tag" do
      let(:string) { "<tag>" }
      it { should be_instance_of(described_class) }
    end

    context "for an closing tag" do
      let(:string) { "</tag>" }
      it { should be_instance_of(described_class) }
    end
  end

  describe ".parse" do
    subject { described_class.parse(string) }

    context %{for <tag>} do
      let(:string) { %{<tag>} }

      its(:closing?       ) { should be_false }
      its(:name           ) { should == "tag" }
      its(:id             ) { should be_nil }
      its(:class_names    ) { should be_empty }
      its(:parent         ) { should be_nil }
      its(:original_string) { should == "<tag>" }
    end

    context %{for </tag>} do
      let(:string) { %{</tag>} }

      its(:closing?       ) { should be_true }
      its(:name           ) { should == "tag" }
      its(:id             ) { should be_nil }
      its(:class_names    ) { should be_empty }
      its(:parent         ) { should be_nil }
      its(:original_string) { should == "</tag>" }
    end

    context %{for '<TAG>'} do
      let(:string) { %{<TAG>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_false }
    end

    context %{for '</TAG>'} do
      let(:string) { %{</TAG>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_true }
    end

    context %{for '<a12345>'} do
      let(:string) { %{<a12345>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_false }
    end

    context %{for '</a12345>'} do
      let(:string) { %{</a12345>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_true }
    end

    context %{for '<a>'} do
      let(:string) { %{<a>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_false }
    end

    context %{for '</a>'} do
      let(:string) { %{</a>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_true }
    end

    context %{for '<A>'} do
      let(:string) { %{<A>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_false }
    end

    context %{for '</A>'} do
      let(:string) { %{</A>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_true }
    end

    context %{for '<a_b_c>'} do
      let(:string) { %{<a_b_c>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_false }
    end

    context %{for '</a_b_c>'} do
      let(:string) { %{</a_b_c>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_true }
    end

    context %{for '<_abc>'} do
      let(:string) { %{<_abc>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_false }
    end

    context %{for '</_abc>'} do
      let(:string) { %{</_abc>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_true }
    end

    context %{for '<abc_>'} do
      let(:string) { %{<abc_>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_false }
    end

    context %{for '</abc_>'} do
      let(:string) { %{</abc_>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_true }
    end

    context %{for '<_>'} do
      let(:string) { %{<_>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_false }
    end

    context %{for '</_>'} do
      let(:string) { %{</_>} }
      it { should be_instance_of(described_class) }
      its(:closing?) { should be_true }
    end

    context %{for attrs put into double quotes: <tag id="theId" class="class_1 class_2">} do
      let(:string) { %{<tag id="theId" class="class_1 class_2">} }

      its(:closing?       ) { should be_false }
      its(:name           ) { should == "tag" }
      its(:id             ) { should == "theId" }
      its(:class_names    ) { should == ["class_1", "class_2"] }
      its(:parent         ) { should be_nil }
      its(:original_string) { should == %{<tag id="theId" class="class_1 class_2">} }
    end

    context %{for attrs put into single quotes: <tag id='theId' class='class_1 class_2'>} do
      let(:string) { %{<tag id='theId' class='class_1 class_2'>} }

      its(:closing?       ) { should be_false }
      its(:name           ) { should == "tag" }
      its(:id             ) { should == "theId" }
      its(:class_names    ) { should == ["class_1", "class_2"] }
      its(:parent         ) { should be_nil }
      its(:original_string) { should == %{<tag id='theId' class='class_1 class_2'>} }
    end

    context %{for attrs in different order: <tag class="class_1 class_2" id="theId">} do
      let(:string) { %{<tag class="class_1 class_2" id="theId">} }

      its(:id             ) { should == "theId" }
      its(:class_names    ) { should == ["class_1", "class_2"] }
    end

    context %{for other attrs present: <tag other="value" id="theId" yet-another="value" class="class_1 class_2">} do
      let(:string) { %{<tag other="value" id="theId" yet-another="value" class="class_1 class_2">} }

      its(:id             ) { should == "theId" }
      its(:class_names    ) { should == ["class_1", "class_2"] }
      its(:original_string) { should == %{<tag other="value" id="theId" yet-another="value" class="class_1 class_2">} }
    end
  end
end
