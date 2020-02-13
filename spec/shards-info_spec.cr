require "./spec_helper"

describe "shards.info" do
  it "renders /" do
    get "/"

    response.status_code.should eq(200)
  end

  it "redirects from old urls" do
    get "/repos/mamantoha/shards-info"

    response.status_code.should eq(301)
  end

  it "renders repository" do
    get "/github/mamantoha/shards-info"

    response.status_code.should eq(404)
  end
end
