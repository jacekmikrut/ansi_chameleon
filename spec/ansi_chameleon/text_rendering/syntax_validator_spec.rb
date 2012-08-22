require "spec_helper"

describe "AnsiChameleon::TextRendering instance" do
  describe "extended with AnsiChameleon::TextRendering::SyntaxValidator" do

    subject(:text_rendering) do
      AnsiChameleon::TextRendering.new(style_sheet_handler)
      .extend(SuperGrabbingModule.new(:methods => super_methods_to_grab, :forward_to => fake_text_rendering))
      .extend(AnsiChameleon::TextRendering::SyntaxValidator)
    end

    let(:style_sheet_handler) { stub(:style_sheet_handler, :value_for => nil) }
    let(:fake_text_rendering) { stub(:fake_text_rendering, :push_closing_tag => nil, :to_s => nil) }

    before { AnsiChameleon::SequenceGenerator.stub(:generate => "sequence") }

    describe "#push_closing_tag" do
      let(:action) { lambda { text_rendering.push_closing_tag(closing_tag) } }
      let(:closing_tag) { stub(:tag, :name => 'tag', :original_string => '</tag>') }

      let(:super_methods_to_grab) { [:push_closing_tag]  }

      context "if the opening tag hasn't been pushed" do

        it { action.should raise_error(SyntaxError, "Encountered </tag> tag that had not been opened yet") }

        it "should not call the super (AnsiChameleon::TextRendering#push_closing_tag) method" do
          fake_text_rendering.should_not_receive(:push_closing_tag)
          begin; action.call; rescue SyntaxError; end
        end
      end

      context "if the opening tag has been pushed" do
        before { text_rendering.push_opening_tag(stub(:tag, :name => 'tag', :parent= => nil)) }

        it { action.should_not raise_error(SyntaxError) }

        it "should call the super (AnsiChameleon::TextRendering#push_closing_tag) method" do
          fake_text_rendering.should_receive(:push_closing_tag).with(closing_tag).once
          begin; action.call; rescue SyntaxError; end
        end
      end
    end

    describe "#to_s" do
      let(:action) { lambda { text_rendering.to_s } }

      let(:super_methods_to_grab) { [:to_s]  }

      context "when one tag has not been closed yet" do
        before do
          text_rendering.push_opening_tag(stub(:tag, :name => 'tag', :parent= => nil, :original_string => '<tag id="id" class="class">'))
        end

        it { action.should raise_error(SyntaxError, 'Tag <tag id="id" class="class"> has been opened but not closed yet') }

        it "should not call the super (AnsiChameleon::TextRendering#to_s) method" do
          fake_text_rendering.should_not_receive(:to_s)
          begin; action.call; rescue SyntaxError; end
        end
      end

      context "when more than one tag have not been closed yet" do
        before do
          text_rendering.push_opening_tag(stub(:tag_1, :name => "tag_1", :parent= => nil, :original_string => '<tag_1 id="id1">'))
          text_rendering.push_opening_tag(stub(:tag_2, :name => "tag_2", :parent= => nil, :original_string => '<tag_2 id="id2">'))
        end

        let(:action) { lambda { text_rendering.to_s } }

        it { action.should raise_error(SyntaxError, 'Tags <tag_1 id="id1">, <tag_2 id="id2"> have been opened but not closed yet') }

        it "should not call the super (AnsiChameleon::TextRendering#to_s) method" do
          fake_text_rendering.should_not_receive(:to_s)
          begin; action.call; rescue SyntaxError; end
        end
      end

      context "when there are no unclosed tags" do

        it { action.should_not raise_error(SyntaxError) }

        it "should call the super (AnsiChameleon::TextRendering#to_s) method" do
          fake_text_rendering.should_receive(:to_s).with(no_args)
          begin; action.call; rescue SyntaxError; end
        end
      end
    end
  end
end
