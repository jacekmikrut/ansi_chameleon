require "spec_helper"

describe AnsiChameleon::ArrayUtils do

  describe ".includes_other_array_items_in_order?" do
    subject { AnsiChameleon::ArrayUtils.includes_other_array_items_in_order?(array, other_array) }

    context "([], [])" do
      let(:array)       { [] }
      let(:other_array) { [] }
      it { should be_true }
    end

    context "([], [:a])" do
      let(:array)       { [  ] }
      let(:other_array) { [:a] }
      it { should be_false }
    end

    context "([:a], [])" do
      let(:array)       { [:a] }
      let(:other_array) { [  ] }
      it { should be_true }
    end

    context "([:a], [:a])" do
      let(:array)       { [:a] }
      let(:other_array) { [:a] }
      it { should be_true }
    end

    context "([:a, :b], [:a])" do
      let(:array)       { [:a, :b] }
      let(:other_array) { [:a    ] }
      it { should be_true }
    end

    context "([:a, :b], [:a, :b])" do
      let(:array)       { [:a, :b] }
      let(:other_array) { [:a, :b] }
      it { should be_true }
    end

    context "([:a, :b], [:b, :a])" do
      let(:array)       { [:a, :b] }
      let(:other_array) { [:b, :a] }
      it { should be_false }
    end

    context "([:a, :b, :c, :d], [:b, :d])" do
      let(:array)       { [:a, :b, :c, :d] }
      let(:other_array) { [    :b,     :d] }
      it { should be_true }
    end

    context "([:a, :b, :c, :d], [:b, :a])" do
      let(:array)       { [:a, :b, :c, :d] }
      let(:other_array) { [    :b, :a    ] }
      it { should be_false }
    end

    context "([:a, :b, :c, :d, :b], [:a, :c, :b])" do
      let(:array)       { [:a, :b, :c, :d, :b] }
      let(:other_array) { [:a,     :c,     :b] }
      it { should be_true }
    end
  end
end
