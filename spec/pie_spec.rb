require File.join(File.expand_path(File.dirname(__FILE__)), "..", "lib", "pie")

describe "making pie" do
  describe "with template" do
    it "has a default template" do
      make_pie {}
      $pie.default_template.should == :image_page
    end
    it "can set an alternate template" do
      make_pie do
        template :foo
      end
      $pie.default_template.should == :foo
    end
  end
  describe "image declaration" do
    it "can declare an image" do
      make_pie do
        image ship:"http://foo.com/ship.png"
      end
      $pie.images[:ship].should == "http://foo.com/ship.png"
    end

    it "can declare multiple image statements" do
      make_pie do
        image ship:"http://foo.com/ship.png"
        image basket:"http://foo.com/basket.png"
      end
      $pie.images[:ship].should == "http://foo.com/ship.png"
      $pie.images[:basket].should == "http://foo.com/basket.png"
    end

    it "can declare multiple images with one statement" do
      make_pie do
        image ship:"http://foo.com/ship.png",
              basket:"http://foo.com/basket.png"
      end
      $pie.images[:ship].should == "http://foo.com/ship.png"
      $pie.images[:basket].should == "http://foo.com/basket.png"
    end
  end

  describe "creates places" do
    it "can create a place without a description" do
      make_pie do
        create_places do
          ship
        end
      end
      $pie.places[:ship].should == {}
    end

    it "cannot create a place if options are invalid (given as a symbol not a Hash)" do
      make_pie do
        create_places do
          result = ship :invalid
          result.should == nil
        end
      end
      $pie.places[:ship].should == nil
    end
    describe "with paths" do
      before do
        make_pie do
          create_places do
            field description:"You are in a large, grassy field. You see many trees to the north and a path to the east"
            forest description:"It is dark in the forest"
            cliff_top description:"The path ends at the top of a steep cliff"
            cliff_bottom description:"You walked off the cliff and fell to your death"
          end
        end
      end
      it "should have links between two places" do
        more_pie do
          map do
            puts "----- inside map block ---"
            path(field:"North", forest:"South")
            path(field:"East", cliff_top:"West")
          end
          place = places[:field]
          place.links.should == {forest:"North", cliff_top:"East"}

        end
      end
      it "should have one way links" do
        more_pie do
          map do
            path(cliff_top:"East", cliff_bottom:NO_WAY_BACK)
          end
          cliff_top = places[:cliff_top]
          cliff_top.should_not == nil
          cliff_top.links.should == { cliff_bottom:"East"}
          cliff_bottom = places[:cliff_bottom]
          cliff_bottom.should_not  == nil
          cliff_bottom.links.should == {}
        end
      end
    end

  end
  describe "can access places" do
    before do
      make_pie do
        create_places do
          ship description:"ookina fune"
          building description:"ookina biru"
          tower description:"ookina towa"
        end
      end
    end

    it "which are accessible by named key (symbol)" do
      ship = $pie.places[:ship]
      ship.should_not be_nil
      ship[:description].should == "ookina fune"
    end
    
    it "which are accessible by named key (string)" do
      ship = $pie.places["ship"]
      ship.should_not be_nil
      ship[:description].should == "ookina fune"
    end

    it "resulting in 2 places" do
      $pie.places.length.should == 3
    end
    
    it "and can find place after named place" do
      building = $pie.places.after(:ship)
      building.should_not be_nil
      building[:description].should == "ookina biru"
    end
   
    it "and finds nil after last place" do
      nothing = $pie.places.after(:tower)
      nothing.should be_nil
    end

    it "and can find place before named place" do
      building = $pie.places.before(:tower)
      building.should_not be_nil
      building[:description].should == "ookina biru"
    end

    it "and finds nil before first place" do
      nothing = $pie.places.before(:ship)
      nothing.should be_nil
    end
  end
end
