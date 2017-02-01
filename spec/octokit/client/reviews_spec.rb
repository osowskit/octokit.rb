require 'helper'

describe Octokit::Client::Reviews do
  before do
    Octokit.reset!
    @client = oauth_client
    @client_approver = Octokit::Client.new(:login => "osowskit@github.com", :access_token => ENV["OCTOKIT_TEST_GITHUB_TOKEN_APPROVER"])
  end
  
  context "with repository with a pull request" do    
    before do
      @repo = @client.create_repository("api-repo", :auto_init => true)
      master_ref = @client.ref(@repo.full_name, "heads/master")
      @client.create_ref(@repo.full_name, "heads/branch-for-pr", master_ref.object.sha)
      @content = @client.create_contents(@repo.full_name, "lib/test.txt", "Adding content", "File Content", :branch => "branch-for-pr")

      args = [@repo.full_name, "master", "branch-for-pr", "A new PR", "The Body"]
      @pull = @client.create_pull_request(*args)
    end
  
    after do
      begin
        @client.delete_repository(@repo.full_name)
      rescue Octokit::NotFound
      end
    end
  
        
    describe ".reviews", :vcr do
      it "returns an array of reviews" do
        reviews = @client.reviews(@repo.full_name, @pull.number)
        expect(reviews).to be_kind_of Array
        assert_requested :get, github_url("/repos/#{@repo.full_name}/pulls/#{@pull.number}/reviews")
      end # returns an array of reviews
    end # .reviews

    describe ".approve_review", :vcr do
      it "creates an approve review" do
        args = [@repo.full_name, @pull.number, "APPROVE", ":rock:"]
        review_approve = @client_approver.create_review(*args)
        expect(review_approve.body).to eql(":rock:")
        expect(review_approve.state).to eql("APPROVED")
        assert_requested :post, github_url("/repos/#{@repo.full_name}/pulls/#{@pull.number}/reviews")  
      end # creates an approve review
    end # .approve_review
    
    describe ".comment_review", :vcr do
      it "creates a comment review" do
        args = [@repo.full_name, @pull.number, "COMMENT", ":banana:s"]
        review_comment = @client.create_review(*args)  
        expect(review_comment.body).to eql(":banana:s")
        expect(review_comment.state).to eql("COMMENTED")
        assert_requested :post, github_url("/repos/#{@repo.full_name}/pulls/#{@pull.number}/reviews")
      end # creates a comment review
    end # .comment_review

    context "with a COMMENT review" do
      before do
        args = [@repo.full_name, @pull.number, "COMMENT", ":banana:s"]
        @review_context = @client.create_review(*args)  
      end
      
      describe ".review", :vcr do          
        it "gets a single review" do
          result = @client.review(@repo.full_name, @pull.number, @review_context.id)
          expect(result.body).to eq(":banana:s")
          expect(result.state).to eq("COMMENTED")
          assert_requested :get, github_url("/repos/#{@repo.full_name}/pulls/#{@pull.number}/reviews/#{@review_context.id}")
        end # gets a single review
      end # .review              
    end # with a COMMENT review
    
    context "with an APPROVE review" do
      before do
        args = [@repo.full_name, @pull.number, "APPROVE", ":rock:"]
        @review_context = @client_approver.create_review(*args)  
      end
  
      describe ".review", :vcr do          
        it "gets a single review" do
          result = @client.review(@repo.full_name, @pull.number, @review_context.id)
          expect(result.body).to eq(":rock:")
          expect(result.state).to eq("APPROVED")
          assert_requested :get, github_url("/repos/#{@repo.full_name}/pulls/#{@pull.number}/reviews/#{@review_context.id}")
        end # gets a single review
      end # .review 
      
      describe ".dismiss_review", :vcr do          
        it "dismisses a single review" do
          result = @client.dismiss_review(@repo.full_name, @pull.number, @review_context.id, "automated dismissal")
          expect(result.state).to eq("DISMISSED")
          assert_requested :put, github_url("/repos/#{@repo.full_name}/pulls/#{@pull.number}/reviews/#{@review_context.id}/dismissals")
        end # dismisses a single review
      end # .dissmiss_review  
      
      describe ".request_changes_review", :vcr do
        it "creates an request changes review" do
          args = [@repo.full_name, @pull.number, "REQUEST_CHANGES", ":question:"]
          review = @client_approver.create_review(*args)
          expect(review.body).to eq(":question:")
          expect(review.state).to eq("CHANGES_REQUESTED")
          assert_requested :post, github_url("/repos/#{@repo.full_name}/pulls/#{@pull.number}/reviews"), times: 2  
        end # creates an approve review
      end # .approve_review

    end # with a APPROVE review      
  end # with repository with a pull request
end
