class EmailPageMail
  attr_reader :page, :data
  def initialize(page, data, request)
    @page, @data, @request = page, data, request
  end
  
  def from
    data[:from]
  end
  
  def page_to_email
    Page.find(@data[:page_id])
  end
  
  def page_to_email_url
    "#{@request.protocol}#{@request.host}#{page_to_email.url}"
  end
  
  def send
    to = @data[:to]
    subject = @data[:subject] || "Recomendation"
    body = page.part(:email) ? page.render_part(:email) : default_body
    
    EmailPageMailer.deliver_generic_mail(
      :recipients => to,
      :from => from,
      :subject => subject,
      :headers => { 'Reply-To' => from },
      :body => body
    )
    page_to_email.update_emailed_count
  end
  
  protected
  
    def default_body
      %(#{from} enjoyed reading this page #{page_to_email_url} and thinks you might too.)
    end  
end