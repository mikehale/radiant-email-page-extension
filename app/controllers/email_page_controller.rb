class EmailPageController < ApplicationController
  session :off
  no_login_required
  skip_before_filter :verify_authenticity_token
  
  def index    
    email_page.page_id_to_email = params[:page_id]
    email_page.request, email_page.response = request, response
    render :text => email_page.render
  end
  
  def create
    page_to_email = Page.find(params[:page_id])
    Mail.new(params, full_url(page_to_email)).send
    page_to_email.update_emailed_count
    redirect_to page_to_email.url
  end
  
  private
  
  def full_url(page)
    "#{request.protocol}#{request.domain}#{page.url}"
  end
  
  def email_page
    Page.find_by_title('Email Page')
  end
  
end

class Mail
  def initialize(params, page_url)
    @params = params
    @page_url = page_url
  end
  
  def send
    to = @params[:to]
    from = @params[:from]
    subject = @params[:subject] || "Recommendation"
    
    Mailer.deliver_generic_mail(
      :recipients => to,
      :from => from,
      :subject => subject,
      :headers => { 'Reply-To' => from },
      :plain_body => %(#{from} enjoyed reading this page #{@page_url} and thinks you might too.)
    )    
  end
end