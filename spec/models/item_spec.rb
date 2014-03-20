require 'spec_helper'

describe Item do
  before(:all) do
	  @item = FactoryGirl.create(:item)
  end

  context "initialize params" do
	  it "has an id" do
		  expect(@item.id).to_not be_nil
		  expect(@item.id).to be_a(Integer)
		  expect(@item.id).to eq(622)
	  end
	  
	  it "has a name" do
	    expect(@item.name).to_not be_nil
	    expect(@item.name).to be_a(String)
	    expect(@item.name).to eq("Stabber")
	  end
	  
	  it "optionally includes images" do
	    expect(@item.images).to_not be_nil
	    expect(@item.images).to be_a(Hash)
	  end
	end
	
	context "images" do
	  it "contain a small size" do
	    expect(@item.images["small"]).to_not be_nil
	    expect(@item.images["small"]).to be_a(String)
	  end
	  
	  it "contain a thumbnail size" do
	    expect(@item.images["thumb"]).to_not be_nil
	    expect(@item.images["thumb"]).to be_a(String)
	  end
	end
	
	context "search all" do
	  it "returns a list of Items" do
	    expect(Item.all).to_not be_nil
	    expect(Item.all).to be_a(Array)
	    Item.all.each{ |item| expect(item).to be_a(Item) }
	  end
	end
	
	context "search" do
	  context "with valid id" do
	    it "returns an Item" do
	      expect(Item.find(622)).to be_a(Item)
	    end
	  end
	  
	  context "with invalid id" do
	    it "returns a nil Item" do
	      item = Item.find(0)
	      expect(item.id).to be_nil
	      expect(item.name).to be_nil
	    end
	  end
	end
end
