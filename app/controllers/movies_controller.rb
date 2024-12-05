class MoviesController < ApplicationController
  ENDPOINT = "http://www.omdbapi.com/"

  def search
    title = params[:title]

    if title.blank?
      render json: { error: "The movie title is mandatory!" }, status: :bad_request
      return
    end

		all_movies = []
    page = 1
		api_key = ENV['OMDB_API_KEY']

    loop do
			response = HTTParty.get(ENDPOINT, query: { apikey: api_key, s: title, type: "movie", page: page  })
      
      if response.success? && response.parsed_response["Response"] == "True"
        movies = response.parsed_response["Search"]
        all_movies.concat(movies)
        
        break if movies.size < 10
      else
        render json: { error: response.parsed_response["Error"] }
        return
      end

      page += 1
    end

    render json: all_movies
  end

	def show
    movie_id = params[:id]

    if movie_id.blank?
      render json: { error: "The movie ID is mandatory!" }, status: :bad_request
      return
    end

		api_key = ENV['OMDB_API_KEY']
    response = HTTParty.get(ENDPOINT, query: { apikey: api_key, i: movie_id })

    if response.success? && response.parsed_response["Response"] == "True"
			# Pretty print - remove status of API Call
      prettt_response = response.parsed_response.except("Response")
      render json: prettt_response
    else
      render json: { error: response.parsed_response["Error"] }
    end
  end

end
