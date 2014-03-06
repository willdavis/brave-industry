require 'spec_helper'

describe Region do
  before(:all) do
	  #Uncomment to test performance improvements from instance variables
	  #Make sure to comment out the :before block
	  @region = FactoryGirl.create(:region)
  end

=begin
  before(:each) do
    @region = FactoryGirl.create(:region)
  end
=end

  context "initialize params" do
	  it "has an id" do
		  expect(@region.id).to_not be_nil
		  expect(@region.id).to be_a(Integer)
		  expect(@region.id).to eq(10000002)
	  end
	  
	  it "has a name" do
	    expect(@region.name).to_not be_nil
	    expect(@region.name).to be_a(String)
	    expect(@region.name).to eq("The Forge")
	  end
	end
	
	context "search" do
	  context "with valid id" do
	    it "returns a region" do
	      region = Region.find(10000002)
	      expect(region.id).to_not be_nil
	      expect(region.name).to_not be_nil
	      
	      expect(region.id).to be_a(Integer)
	      expect(region.name).to be_a(String)
	    end
	  end
	  
	  context "with invalid id" do
	    it "returns nil" do
	      region = Region.find(0)
	      
	      expect(region.id).to be_nil
	      expect(region.name).to be_nil
	    end
	  end
	end
	
	context "search all result" do
	  it "returns an array containing all regions" do
	    expect(Region.all).to be_a(Array)
	  end
	  
	  it "size should be 67 regions" do
	    expect(Region.all.size).to eq(67)
	  end
	  
	  it "returns a name and id for all regions" do
	    Region.all.each do |region|
	      expect(region.id).to_not be_nil
	      expect(region.id).to be_a(Integer)
	      
	      expect(region.name).to_not be_nil
	      expect(region.name).to be_a(String)
	    end
	  end
	end
end

