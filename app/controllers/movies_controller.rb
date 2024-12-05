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
        render json: { error: "Oops - Error while fetching OMDB data!" }
        return
      end

      page += 1
    end

    render json: pretty_print(all_movies)
  end

	private

	def pretty_print movies
    movies.map do |movie|
      {
        title: movie["Title"],
        year: movie["Year"],
        imdb_id: movie["imdbID"],
        type: movie["Type"],
        poster: movie["Poster"]
      }
    end
  end

end
