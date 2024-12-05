class MoviesController < ApplicationController
  ENDPOINT = "http://www.omdbapi.com/"

  api :GET, '/search', 'Display brief information for the movies that include in their name your keyword. Search through ALL pages & extract ONLY movies.'
  param :title, String, required: true, desc: 'Title of the movie'
  
  error 400, 'Bad Request / The movie title is mandatory!'
  error 500, 'Internal Server Error / Could not connect with OMDBAPI'

	example <<-EOS
		Request:
			GET /search?title=Andrei
		Response:
			{
				[	
					{
						"Title": "Andrei Rublev",
						"Year": "1966",
						"imdbID": "tt0060107",
						"Type": "movie",
						"Poster": "https://m.media-amazon.com/images/M/MV5BY2I4YzZjZDgtNWQzNC00MDdhLWFiZTItZTAwODY2ZmQzMDQwXkEyXkFqcGc@._V1_SX300.jpg"
					},
					{
						"Title": "War and Peace, Part I: Andrei Bolkonsky",
						"Year": "1965",
						"imdbID": "tt0059884",
						"Type": "movie",
						"Poster": "https://m.media-amazon.com/images/M/MV5BMGZiZTIyZjEtOGNmZS00OGQ2LTgzMmMtZWM4ZGMyNjc1ZDMwXkEyXkFqcGc@._V1_SX300.jpg"
					},
					....
				]
			}
	EOS
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

	api :GET, '/movies/:id', 'Retrieve movie details by ID. If the URL ends with .pdf we call the async job of sending email'
  param :id, String, required: true, desc: 'Movie ID (e.g., tt0059884)'
  param :email, String, required: true, desc: 'Email address to send the PDF (only for PDF requests)'
  error 400, 'Bad Request / The movie ID is mandatory! / The email is mandatory!'
  error 500, 'Internal Server Error / Could not connect with OMDBAPI'

  example <<-EOS
    JSON Request:
      GET /movies/tt0059884
    JSON Response:
			{
				"Title": "War and Peace, Part I: Andrei Bolkonsky",
				"Year": "1965",
				"Rated": "Not Rated",
				"Released": "23 Jul 1966",
				"Runtime": "147 min",
				"Genre": "Drama, War",
				"Director": "Sergey Bondarchuk",
				"Writer": "Lev Tolstoy, Sergey Bondarchuk, Vasiliy Solovyov",
				"Actors": "Lyudmila Saveleva, Sergey Bondarchuk, Vyacheslav Tikhonov",
				"Plot": "Napoleon's tumultuous relations with Russia including his disastrous 1812 invasion serve as the backdrop for the tangled personal lives of five aristocratic Russian families.",
				"Language": "Russian",
				"Country": "Soviet Union",
				"Awards": "1 win",
				....
			}

    PDF Request:
      GET /movies/tt0059884.pdf?email=user@example.com
    PDF Response:
      {
        "message": "Request accepted! PDF generation starting soon..."
				* Async job
				* It opens a new page simulating email sending
				* The email contains the movie name and a PDF as attachment with the poster as image and all movie details
      }
  EOS
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
