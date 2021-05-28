require "./spec_helper"

describe "shards.info" do
  it "renders /" do
    get "/"

    response.status_code.should eq(200)
  end

  it "renders repository" do
    get "/github/crystal-lang/crystal"

    response.status_code.should eq(200)
  end

  it "renders 404 if repository not found" do
    get "/github/undefined/undefined"

    response.status_code.should eq(404)
  end

  it "renders 403 for Admin Area" do
    get "/admin"

    response.status_code.should eq(403)
  end
end
