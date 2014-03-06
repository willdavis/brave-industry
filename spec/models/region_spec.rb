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
	  end
	end
	
	context "search all result" do
	  it "returns an array containing all regions" do
	    expect(Region.all).to be_a(Array)
	  end
	  
	  it "size should be 67 regions" do
	    expect(Region.all.size).to eq(67)
	  end
	end
end

