require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    it "returns http success" do
      get 'index'
      response.should be_success
    end
  end
  
  describe "GET 'health_check'" do
    it "returns http success" do
      get 'health_check'
      response.should be_success
    end
  end

end
