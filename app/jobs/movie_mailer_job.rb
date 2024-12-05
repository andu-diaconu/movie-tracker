require 'prawn'
require 'open-uri'

class MovieMailerJob < ApplicationJob
  queue_as :default

  def perform(to_email, movie_data)
    pdf_path = generate_pdf(movie_data)
    movie_title = movie_data['Title']

    MovieMailer.send_details(to_email, pdf_path, movie_title).deliver_now
  end

  private

  def generate_pdf(data)
    pdf = Prawn::Document.new

    pdf.text data['Title'], size: 20, style: :bold
    pdf.move_down 20

    pdf.text "Year: #{data['Year']}"
    pdf.move_down 3

    pdf.text "Genre: #{data['Genre']}"
    pdf.move_down 3

    pdf.text "Director: #{data['Director']}"
    pdf.move_down 3

    pdf.text "Actors: #{data['Actors']}"
    pdf.move_down 3

    pdf.text "Plot: #{data['Plot']}"
    pdf.move_down 3

    pdf.text "IMDB Rating: #{data['imdbRating']}"
    pdf.move_down 3

    pdf.text "Language: #{data['Language']}"
    pdf.move_down 3

    pdf.text "Awards: #{data['Awards']}"

    image_path = Rails.root.join("tmp", "movie_poster_#{SecureRandom.hex(10)}.jpg")
    File.open(image_path, 'wb') do |file|
      file.write open(data['Poster']).read
    end

    pdf.move_down 15

    pdf.image image_path, width: 150, height: 225, at: [0, pdf.cursor]

    pdf_path = Rails.root.join("tmp", "movie_#{data['imdbID']}.pdf")
    pdf.render_file(pdf_path)

    pdf_path.to_s
  end
end
