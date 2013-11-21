require 'spec_helper'

describe Blueprint do
  before(:each) do
    @blueprint = FactoryGirl.create(:blueprint)
  end
  
  context "attributes" do
  	it "contain an id" do
  		@blueprint.id.should_not be_nil
  		@blueprint.id.should be_a(Integer)
  	end
  	
  	it "contain an invented flag" do
  		@blueprint.invented.should_not be_nil
  		@blueprint.invented.should be_a(Integer)
  	end
  	
  	it "contain a modifier for Material Efficiency" do
  		@blueprint.material_efficiency.should be_a(Integer)
  		@blueprint.material_efficiency = nil
  		@blueprint.material_efficiency.should be_nil
  	end
  	
  	it "contain a modifier for Production Efficiency"
  end
  
  context "invention" do
  	it "is hard!"
  	it "returns list of required datacores"
  	it "returns the required data interface"
  	it "returns list of viable data decryptors"
  	it "returns list of viable modules"
  end
  
  context "skills" do
  	it "returns a list of all required skills"
  	it "can be filtered to only return required skills for manufacturing"
  	it "can be filtered to only return required skills for research"
  	it "can be filtered to only return required skills for invention"
  end
  
  context "EVEData API integration" do
  	it "looks up a blueprint by it's id"
  	it "looks up a blueprint's raw material requirements by it's products id"
  	it "looks up a blueprint's extra material requirements by it's id"
  end
end
