require 'spec_helper'

describe SolarSystem do
  before(:all) do
	  #Uncomment to test performance improvements from instance variables
	  #Make sure to comment out the :before block
	  @solar = FactoryGirl.create(:solar_system)
  end

=begin
  before(:each) do
    @solar = FactoryGirl.create(:solar)
  end
=end

  context "initialize params" do
	  it "has an id" do
		  expect(@solar.id).to_not be_nil
		  expect(@solar.id).to be_a(Integer)
		  expect(@solar.id).to eq(30000015)
	  end
	  
	  it "has a name" do
	    expect(@solar.name).to_not be_nil
	    expect(@solar.name).to be_a(String)
	    expect(@solar.name).to eq("Sendaya")
	  end
	end
	
	context "search" do
	  context "with valid id" do
	    it "returns a solar system" do
	      solar = SolarSystem.find_by_id(30000015)
	      expect(solar.id).to_not be_nil
	      expect(solar.name).to_not be_nil
	      
	      expect(solar.id).to be_a(Integer)
	      expect(solar.name).to be_a(String)
	    end
	  end
	  
	  context "with a valid name" do
	    it "returns a solar system" do
	      solar = SolarSystem.find_by_name("Sendaya")
	      expect(solar.id).to_not be_nil
	      expect(solar.name).to_not be_nil
	      
	      expect(solar.id).to be_a(Integer)
	      expect(solar.name).to be_a(String)
	    end
	  end
	  
	  context "with invalid id" do
	    it "returns nil" do
	      solar = SolarSystem.find_by_id(0)
	      
	      expect(solar.id).to be_nil
	      expect(solar.name).to be_nil
	    end
	  end
	  
	  context "with invalid name" do
	    it "returns nil" do
	      solar = SolarSystem.find_by_name("NOT A SYSTEM")
	      
	      expect(solar.id).to be_nil
	      expect(solar.name).to be_nil
	    end
	  end
	end
	
	context "search all result" do
	  it "returns an array containing all solar systems" do
	    expect(SolarSystem.all).to be_a(Array)
	  end
	  
	  it "returns a name and id for all solar systems" do
	    SolarSystem.all.each do |solar|
	      expect(solar.id).to_not be_nil
	      expect(solar.id).to be_a(Integer)
	      
	      expect(solar.name).to_not be_nil
	      expect(solar.name).to be_a(String)
	    end
	  end
	end
end

