class EmailPageController < ApplicationController
  session :off
  no_login_required
  skip_before_filter :verify_authenticity_token
  
  def index
    email_page = Page.find_by_class_name("EmailPage")
    email_page.page_id_to_email = params[:page_id]
    email_page.request, email_page.response = request, response
    render :text => email_page.render
  end
  
  def create
    email_page = Page.find_by_class_name("EmailPage")
    mail = Mail.new(email_page, params, request)
    email_page.last_mail = mail
    
    mail.send
    redirect_to mail.page_to_email.url
  end    
end

class Mail
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
    plain_body = page.part(:email) ? page.render_part(:email) : default_body
    
    Mailer.deliver_generic_mail(
      :recipients => to,
      :from => from,
      :subject => subject,
      :headers => { 'Reply-To' => from },
      :plain_body => plain_body
    )
    page_to_email.update_emailed_count
  end
  
  protected
  
    def default_body
      %(#{from} enjoyed reading this page #{page_to_email_url} and thinks you might too.)
    end  
end