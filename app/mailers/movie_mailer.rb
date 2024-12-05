class MovieMailer < ApplicationMailer
  def send_details(to_email, pdf_path, title)
    attachments['your_movie.pdf'] = File.read(pdf_path)
    @title = title
    
    mail(to: to_email, subject: 'Your Movie Details')
  end
end
