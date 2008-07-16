require 'ruby-debug'
class EmailPageController < ApplicationController
  session :off
  no_login_required
  skip_before_filter :verify_authenticity_token
  
  def index
    email_page.request, email_page.response = request, response
    render :text => email_page.render
  end
  
  def create
    mail = EmailPageMail.new(email_page, params, request)
    email_page.last_mail = mail
    if mail.send
      redirect_to "#{mail.page_to_email.url}"
    else
      email_page.request, email_page.response = request, response
      render :text => email_page.render
    end
  end
  
  def email_page
    unless @email_page
      @email_page = Page.find_by_class_name("EmailPage")
      @email_page.page_id_to_email = params[:page_id]
    end
    @email_page
  end
end