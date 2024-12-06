# README

The project use these versions

* Ruby version: 2.7.4
* Rails 7

To run the app on you machine do the following:

1. Clone the Repository:
* git clone https://github.com/your-username/movie-search-api.git
* cd movie-tracker


2. Install Dependencies:
* bundle install


3. Set Up Environment Variables:
* Create a .env file in the root directory and add the OMDB API key
* OMDB_API_KEY=ea4211fc


4. Start the server
* rails server
* redis-server (brew install redis if needed)
* sidekiq

Test the application:

1. Search movie(s) by title
* URL: GET /search?title=<movie_title>
* Description: Searches only for movies (not series, episodes, etc) by title, on all pages(not just the first batch of ten)

2. Search movie by ID
* URL: GET /movies/:id
* Description: Retrieves movie details by IMDb ID. (eg: tt0059884)

3. Async job
* URL: GET /movies/:id.pdf?email=<your_email>
* Description: Sends a PDF of the movie details & a poster to the specified email.
