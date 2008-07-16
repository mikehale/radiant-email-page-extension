class EmailPageMail
  attr_reader :page, :data, :errors
  def initialize(page, data, request)
    @page, @data, @request = page, data, request
    @errors = {}
  end
  
  def from
    data[:from]
  end
  
  def recipients
    data[:recipients]
  end
  
  def page_to_email
    Page.find(@data[:page_id])
  end
  
  def page_to_email_url
    "#{@request.protocol}#{@request.host}#{page_to_email.url}"
  end
  
  def valid?
    valid = true
    
    if from.blank?
      valid = false
      errors['from'] = "is required"
    end
    
    if recipients.blank?
      valid = false
      errors['recipients'] = "is required"
    end
    
    valid
  end
  
  def send
    return false if not valid?
    
    subject = @data[:subject] || "Recomendation"
    body = page.part(:email) ? page.render_part(:email) : default_body
    
    result = EmailPageMailer.deliver_generic_mail(
      :recipients => recipients,
      :from => from,
      :subject => subject,
      :headers => { 'Reply-To' => from },
      :body => body
    )
    page_to_email.update_emailed_count
    result
  end
  
  protected
  
    def default_body
      %(#{from} enjoyed reading this page #{page_to_email_url} and thinks you might too.)
    end  
end