require 'spec_helper'

describe Market do
  before(:all) do
	  @market = FactoryGirl.create(:market)
  end

  context "initialize params" do
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
	  
	  it "has raw market data" do
	    expect(@market.raw_data).to_not be_nil
	    expect(@market.raw_data).to be_a(Hash)
	    expect(@market.raw_data["items"]).to be_a(Array)
	  end
	end
	
	context "region" do
	  it "has a name" do
	    expect(@market.region).to_not be_nil
	    expect(@market.region).to be_a(Region)
	    
	    expect(@market.region.name).to_not be_nil
	    expect(@market.region.name).to be_a(String)
	  end
	end
	
	context "item" do
	  it "has an id" do
	    expect(@market.item.id).to_not be_nil
	    expect(@market.item.id).to be_a(Integer)
	  end
	  
	  it "has a name" do
	    expect(@market.item.name).to_not be_nil
	    expect(@market.item.name).to be_a(String)
	    expect(@market.item.image['thumb']).to_not be_nil
	    expect(@market.item.image['thumb']).to be_a(String)
	  end
	end
	
	context "search" do
	  context "with valid ids" do
	    it "returns a market" do
	      market = Market.find(10000002, 622)
	      expect(market.region_id).to_not be_nil
	      expect(market.type_id).to_not be_nil
	      expect(market.raw_data).to_not be_nil
	      
	      expect(market.region_id).to be_a(Integer)
	      expect(market.type_id).to be_a(Integer)
	      
	      expect(market.raw_data).to be_a(Hash)
	      expect(market.raw_data["totalCount"]).to be_a(Integer)
	      expect(market.raw_data["items"]).to be_a(Array)
	    end
	  end
	  
	  context "with invalid ids" do
	    it "returns nil" do
	      market = Market.find(0,0)
	      
	      expect(market.region_id).to eq(0)
	      expect(market.type_id).to eq(0)
	      expect(market.raw_data).to be_a(Hash)
	      
	      expect(market.raw_data["exceptionType"]).to be_a(String)
	      expect(market.raw_data["exceptionType"]).to eq("NotFoundError")
	      
	      expect(market.raw_data["message"]).to be_a(String)
	      expect(market.raw_data["message"]).to eq("Type not listed on market")
	    end
	  end
	end
end
