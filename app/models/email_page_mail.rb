class EmailPageMail
  attr_reader :page, :data, :errors
  def initialize(page, data, request)
    @page, @data, @request = page, data, request
    @errors = {}
  end
  
  def from
    @data[:from].strip
  end
  
  def recipients
    @data[:recipients].split(/,/).collect{|e| e.strip }.find_all{|e| !e.blank? }
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
      errors['recipients'] = "are required"
    end

    if !valid_email?(recipients)
      errors['recipients'] = 'are invalid'
      valid = false
    end
        
    if !valid_email?(from)
      errors['from'] = 'is invalid'
      valid = false
    end
    
    valid
  end
  
  def send
    return false if not valid?
    subject = @data[:subject] || "Recomendation"
    plain_body = page.part(:email) ? page.render_part(:email) : default_body
    html_body = page.render_part(:email_html) || nil
    
    result = EmailPageMailer.deliver_generic_mail(
      :recipients => recipients,
      :from => from,
      :subject => subject,
      :headers => { 'Reply-To' => from },
      :plain_body => plain_body,
      :html_body => html_body
    )
    page_to_email.update_emailed_count
    result
  end
  
  protected
    def valid_email?(email)
      if email.is_a? String
        (email.blank? ? true : email =~ /.@.+\../)
      elsif email.is_a? Array
        email.collect{|e| e.strip}.all?{|e| valid_email?(e) }
      end
    end
  
    def default_body
      %(#{from} enjoyed reading this page #{page_to_email_url} and thinks you might too.)
    end  
end