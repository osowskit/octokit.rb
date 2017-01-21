module Octokit
  class Client

    # Methods for the Reviews API
    #
    # @see https://developer.github.com/v3/reviews/
    module Reviews

      # List reviews on a pull request
      # 
      # @param repo [Integer, String, Hash, Repository] A GitHub repository
      # @param number [Integer] The number of the pull request

      def reviews(repo, number, options = {})
        options = ensure_api_media_type(:reviews, options)
        # paginate?
        get "#{Repository.path repo}/pulls/#{number}/reviews", options
      end

      # Get a single reviews
      # 
      # @param repo [Integer, String, Hash, Repository] A GitHub repository
      # @param number [Integer] The id of the pull request
      # @param id [Integer] The id of the pull request
      
      def review(repo, number, id, options = {})
        options = ensure_api_media_type(:reviews, options)
        get "#{Repository.path repo}/pulls/#{number}/reviews/#{id}", options
      end

      # Get comments for a single review
      # 
      # @param repo [Integer, String, Hash, Repository] A GitHub repository
      # @param number [Integer] The id of the pull request
      # @param id [Integer] The id of the pull request
      
      def review_comments(repo, number id, options = {})
        options = ensure_api_media_type(:reviews, options)
        get "#{Repository.path repo}/pulls/#{number}/reviews/#{id}/comments", options
      end

      # Delete a review
      #
      # @param repo [Integer, String, Hash, Repository] A GitHub repository
      # @param number [Integer] Pull Request number
      # @param id [Integer] Review id
      #
      def delete_review(repo, number, id, options = {})
        options = ensure_api_media_type(:reviews, options)
        boolean_from_response :delete, "#{Repository.path repo}/pulls/#{number}/reviews/#{id}", options
      end


      # Create a pull request review
      # @param repo [Integer, String, Hash, Repository] A GitHub repository
      # @param number [Integer] The number of the pull request
      #
      def create_review(repo, number, body = nil, event, options = {})
        review = {
          :event  => event,
        }
        review[:body] = body unless body.nil?
        options = ensure_api_media_type(:reviews, options.merge(review))
        post "#{Repository.path repo}/pulls/#{number}/reviews", options
      end

      # Submit a pull request review
      # @param repo [Integer, String, Hash, Repository] A GitHub repository
      # @param number [Integer] The number of the pull request
      # @param id [Integer] The id of the review
      #
      def submit_review(repo, number, id, body = nil, event, options = {})
        review = {
          :event  => event,
        }
        review[:body] = body unless body.nil?
        options = ensure_api_media_type(:reviews, options.merge(review))
        post "#{Repository.path repo}/pulls/#{number}/reviews/#{id}/events", options
      end

      def dismiss_review(repo, number, id, options = {})
        options = ensure_api_media_type(:reviews, options)
        put "#{Repository.path repo}/pulls/#{number}/reviews/#{id}/dismissals", options)
      end
    end
  end
end
