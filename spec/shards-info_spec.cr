require "./spec_helper"

describe "shards.info" do
  it "renders /" do
    get "/"

    response.status_code.should eq(200)
  end

  it "renders repository" do
    get "/repos/mamantoha/shards-info"

    response.status_code.should eq(200)
  end

end
