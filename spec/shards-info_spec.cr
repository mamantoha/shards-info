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

  it "renders repository dependencies" do
    get "/github/mamantoha/crest"

    response.status_code.should eq(200)
    response.body.should contain("Dependencies (1)")
    response.body.should contain("crystal")
  end

  it "renders tag repositories" do
    get "/tags/shard"

    response.status_code.should eq(200)
    response.body.should contain("shard")
    response.body.should contain("crystal-lang")
    response.body.should contain("crystal")
  end

  it "renders dependent repositories" do
    get "/github/crystal-lang/crystal/dependents"

    response.status_code.should eq(200)
    response.body.should contain("mamantoha")
    response.body.should contain("crest")
  end

  it "renders 404 if repository not found" do
    get "/github/undefined/undefined"

    response.status_code.should eq(404)
  end

  it "renders 404 for page numbers that are too large" do
    get "/repositories?page=509742457"

    response.status_code.should eq(404)
  end

  it "renders 403 for Admin Area" do
    get "/admin"

    response.status_code.should eq(403)
  end
end
