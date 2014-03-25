require 'spec_helper'

describe Market do
  before(:each) do
	  @market = FactoryGirl.create(:market)
  end

  context "default initialize params" do
    it "has a location" do
      expect(@market.location).to_not be_nil
      expect(@market.location).to be_a(String)
      expect(@market.location).to eq("region")
    end
    
	  it "has a region id" do
		  expect(@market.region_id).to_not be_nil
		  expect(@market.region_id).to be_a(Integer)
		  expect(@market.region_id).to eq(10000002)
	  end
	  
	  it "has a product id" do
	    expect(@market.type_id).to_not be_nil
	    expect(@market.type_id).to be_a(Integer)
	    expect(@market.type_id).to eq(622)
	  end
	end
	
	context "in region" do
	  it "has it's location set as a region" do
	    expect(@market.location).to eq("region")
	  end
	  
	  it "has a region name" do
	    expect(@market.region).to_not be_nil
	    expect(@market.region).to be_a(Region)
	    
	    expect(@market.region.name).to_not be_nil
	    expect(@market.region.name).to be_a(String)
	  end
	  
	  it "has a region id" do
	    expect(@market.region.id).to_not be_nil
	    expect(@market.region.id).to be_a(Integer)
	  end
	end
	
	context "in solar system" do
	  it "has it's location set as a solar system" do
	    @market.location = "system"
	    expect(@market.location).to eq("system")
	  end
	  
	  it "has a solar system name" do
	    expect(@market.solar_system.name).to_not be_nil
	    expect(@market.solar_system.name).to be_a(String)
	  end
	  
	  it "has a solar system id" do
	    expect(@market.solar_system.id).to_not be_nil
	    expect(@market.solar_system.id).to be_a(Integer)
	  end
	end
	
	context "item" do
	  it "is an Item object" do
	    expect(@market.item).to_not be_nil
	    expect(@market.item).to be_a(Item)
	  end
	end
	
	context "search" do
	  context "by region" do
	    context "with valid region id" do
	      it "returns a market" do
	        market = Market.find_by_region(10000002, 622)
	        expect(market.region.id).to_not be_nil
	        expect(market.item.id).to_not be_nil
	        
	        expect(market.region.id).to be_a(Integer)
	        expect(market.region.id).to eq(10000002)
	        
	        expect(market.region.name).to be_a(String)
	        expect(market.region.name).to eq("The Forge")
	        
	        expect(market.item.id).to be_a(Integer)
	        expect(market.item.id).to eq(622)
	        
	        expect(market.item.name).to be_a(String)
	        expect(market.item.name).to eq("Stabber")
	      end
	    end
	    
	    context "with invalid region id" do
	      it "returns nil" do
	        market = Market.find_by_region(0,0)
	        
	        expect(market.region.id).to be_nil
	        expect(market.item.id).to be_nil
	      end
	    end
	  end
	  
	  context "by solar system" do
	    context "with valid system id" do
	      it "returns a market" do
	        market = Market.find_by_system(30000142, 622)
	        expect(market.solar_system.id).to_not be_nil
	        expect(market.item.id).to_not be_nil
	        
	        expect(market.solar_system.id).to be_a(Integer)
	        expect(market.solar_system.id).to eq(30000142)
	        
	        expect(market.solar_system.name).to be_a(String)
	        expect(market.solar_system.name).to eq("Jita")
	        
	        expect(market.item.id).to be_a(Integer)
	        expect(market.item.id).to eq(622)
	        
	        expect(market.item.name).to be_a(String)
	        expect(market.item.name).to eq("Stabber")
	      end
	    end
	    
	    context "with invalid system id" do
	      it "returns nil" do
	        market = Market.find_by_system(0,0)
	        
	        expect(market.solar_system.id).to be_nil
	        expect(market.item.id).to be_nil
	      end
	    end
	  end
	end
end
