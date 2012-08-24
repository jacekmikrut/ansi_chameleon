require "spec_helper"

describe "Single use" do

  it "should properly render the output" do
    AnsiChameleon.render(
      '<p class="poetry">There are <number>3</number> oranges on the table.</p>',
      "p.poetry" => { :effect => :bright }, "number" => { :fg_color => :blue }
    )
    .should == "\e[0m\e[37m\e[40m\e[1m\e[37m\e[40mThere are \e[1m\e[34m\e[40m3\e[1m\e[37m\e[40m oranges on the table.\e[0m\e[37m\e[40m\e[0m"
  end
end

describe "Multiple use" do

  it "should properly render the output" do
    text_renderer = AnsiChameleon::TextRenderer.new("p.poetry" => { :effect => :bright }, "number" => { :fg_color => :blue })

    text_renderer.render('<p class="poetry">There are <number>2</number> oranges on the table.</p>')
    .should == "\e[0m\e[37m\e[40m\e[1m\e[37m\e[40mThere are \e[1m\e[34m\e[40m2\e[1m\e[37m\e[40m oranges on the table.\e[0m\e[37m\e[40m\e[0m"

    text_renderer.render('<p class="poetry">Now, there is only <number>1</number> orange.</p>')
    .should == "\e[0m\e[37m\e[40m\e[1m\e[37m\e[40mNow, there is only \e[1m\e[34m\e[40m1\e[1m\e[37m\e[40m orange.\e[0m\e[37m\e[40m\e[0m"
  end
end

describe "Text with a syntax error:" do

  context "lack of the closing tag" do
    it do
      lambda { AnsiChameleon.render("There are <number>3 oranges on the table.", {}) }
      .should raise_error(SyntaxError, "Tag <number> has been opened but not closed yet")
    end
  end

  context "trying to close a tag that has not been opened" do
    it do
      lambda { AnsiChameleon.render("There are <number>3</amount> oranges on the table.", {}) }
      .should raise_error(SyntaxError, "Encountered </amount> tag that had not been opened yet")
    end
  end
end
