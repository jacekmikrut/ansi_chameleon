require "spec_helper"

describe AnsiChameleon::TextRendering::Stack do

  subject(:stack)

  describe "new instance" do
    it "should not have any items" do
      stack.pop.should be_nil
    end
  end

  describe "#push and #pop" do
    let(:item_1) { { :tag => Struct.new(:parent).new, :outer_style => {} } }
    let(:item_2) { { :tag => Struct.new(:parent).new, :outer_style => {} } }
    let(:item_3) { { :tag => Struct.new(:parent).new, :outer_style => {} } }

    context "after a few items were pushed to the stack" do
      before do
        stack.push(item_1)
        stack.push(item_2)
        stack.push(item_3)
      end

      it "should be possible to pop them from the stack (in reverse order)" do
        stack.pop.should equal(item_3)
        stack.pop.should equal(item_2)
        stack.pop.should equal(item_1)
      end
    end
  end

  describe "#push" do
    let(:tag) { Struct.new(:parent).new }

    context "after a tag was pushed to an empty stack" do
      before { stack.push(:tag => tag, :outer_style => {}) }

      it "should assign nil as the tag's parent" do
        tag.parent.should be_nil
      end
    end

    context "after a tag was pushed to a non-empty stack" do
      let(:tag_1) { Struct.new(:parent).new }
      let(:tag_2) { Struct.new(:parent).new }
      let(:tag_3) { Struct.new(:parent).new }

      before do
        stack.push(:tag => tag_1, :outer_style => {})
        stack.push(:tag => tag_2, :outer_style => {})
        stack.push(:tag => tag_3, :outer_style => {})
      end

      it "should assign the previously pushed tag as the tag's parent" do
        tag_3.parent.should equal(tag_2)
      end
    end
  end

  describe "#items" do
    context "for an empty stack" do
      it { stack.items.should eq([]) }
    end

    context "for a non-empty stack" do
      let(:tag_1) { Struct.new(:parent).new }
      let(:tag_2) { Struct.new(:parent).new }

      before do
        stack.push(:tag => tag_1, :outer_style => {})
        stack.push(:tag => tag_2, :outer_style => {})
      end

      it "should be an array containing the pushed items, from bottom to the top" do
        stack.items.should eq([ { :tag => tag_1, :outer_style => {} },
                                { :tag => tag_2, :outer_style => {} } ])
      end
    end
  end

  describe "#top_tag" do
    context "for an empty stack" do
      it { stack.top_tag.should be_nil }
    end

    context "for a non-empty stack" do
      let(:tag_1) { Struct.new(:parent).new }
      let(:tag_2) { Struct.new(:parent).new }

      before do
        stack.push(:tag => tag_1, :outer_style => {})
        stack.push(:tag => tag_2, :outer_style => {})
      end

      it "should be the most recently pushed tag" do
        stack.top_tag.should equal(tag_2)
      end
    end
  end

  describe "#top_tag_name" do
    context "for an empty stack" do
      it { stack.top_tag_name.should be_nil }
    end

    context "for a non-empty stack" do
      let(:tag_1) { Struct.new(:name, :parent).new("tag 1") }
      let(:tag_2) { Struct.new(:name, :parent).new("tag 2") }

      before do
        stack.push(:tag => tag_1, :outer_style => {})
        stack.push(:tag => tag_2, :outer_style => {})
      end

      it "should be the most recently pushed tag" do
        stack.top_tag_name.should eq("tag 2")
      end
    end
  end
end
