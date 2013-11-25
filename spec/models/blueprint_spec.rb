require 'spec_helper'

describe Blueprint do
  before(:each) do
    @blueprint = FactoryGirl.create(:blueprint)
  end
  
  context "initialize params" do
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
  
  context "details" do
  	it "has a name" do
  		@blueprint.name.should_not be_nil
  		@blueprint.name.should be_a(String)
  	end
  	
  	it "has a waste factor" do
  		@blueprint.base_waste.should_not be_nil
  		@blueprint.base_waste.should be_a(Integer)
  	end
  	
  	it "has a production time" do
  		@blueprint.production_time.should_not be_nil
  		@blueprint.production_time.should be_a(Integer)
  	end
  end
  
  context "product" do
  	it "has an id" do
  		@blueprint.product["id"].should_not be_nil
  		@blueprint.product["id"].should be_a(Integer)
  	end
  	
  	it "has a batch size" do
  		@blueprint.product["batch_size"].should_not be_nil
  		@blueprint.product["batch_size"].should be_a(Integer)
  	end
  end
  
  context "invention" do
  	it "is hard!"
  	it "returns list of required datacores"
  	it "returns the required data interface"
  	it "returns list of viable data decryptors"
  	it "returns list of viable modules"
  end
  
  context "skills" do
  	it "returns a list of all required skills" do
  		@blueprint.skills.should_not be_nil
  		@blueprint.skills.should be_a(Hash)
  	end
  	
  	it "can be filtered to only return required skills for manufacturing" do
  		@blueprint.skills["manufacturing"].should_not be_nil
  		@blueprint.skills["manufacturing"].should be_a(Array)
  		@blueprint.skills["manufacturing"].first.should be_a(Hash)
  	end
  	it "can be filtered to only return required skills for research"
  	it "can be filtered to only return required skills for invention"
  end
  
  context "EVEData API integration" do
  	it "looks up a blueprint's details" do
  		details = @blueprint.get_details
  		details.should_not be_nil
  		details.should be_a(Hash)
  	end
  	
  	it "looks up a blueprint's requirements" do
  		requirements = @blueprint.get_requirements
  		requirements.should_not be_nil
  		requirements.should be_a(Array)
  		requirements.first.should be_a(Hash)
  	end
  end
end
