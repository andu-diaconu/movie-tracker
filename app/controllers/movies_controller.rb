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
      pretty_response = response.parsed_response.except("Response")

			if request.format.pdf?
				if params[:email].present?
					MovieMailerJob.perform_later(params[:email], pretty_response)
					render json: { message: "Request accepted! PDF generation starting soon..." }, status: :accepted
				else
					render json: { error: "The email is mandatory!" }, status: :bad_request
				end
			else
				render json: pretty_response
			end
    else
      render json: { error: response.parsed_response["Error"] }
    end
  end

end
