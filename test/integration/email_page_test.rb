require File.dirname(__FILE__) + '/../test_helper'
require 'ruby-debug'

class EmailPageTest < ActionController::IntegrationTest
  def setup
    @home = Page.create!(:title => 'Home', 
                         :slug => '/', 
                         :breadcrumb => 'home', 
                         :status => Status[:published])
                         
    @page_to_email = Page.create!(:title => 'Cool Page',
                                  :slug => 'cool', 
                                  :breadcrumb => 'cool', 
                                  :status => Status[:published], 
                                  :parent => @home)
                                  
    PagePart.create!(:name => 'body', :page => @page_to_email, :content => cool_page)
                     
    @emailpage = Page.create!(:title => 'Email', 
                             :slug => 'email', 
                             :breadcrumb => 'email', 
                             :status => Status[:published], 
                             :parent => @home, 
                             :class_name => "EmailPage")                             

    @url = "/pages/#{@page_to_email.id}/email_page"
    @full_url = "http://www.example.com#{@page_to_email.url}"
  end
  
  def test_link
    get '/cool'
    assert_select "a[href=#{@url}]", "email this page"
  end
  
  def test_count
    @page_to_email.emailed_count = 999999
    @page_to_email.save
    get '/cool'
    assert_select "#count", "999999"
  end
  
  def test_form
    PagePart.create!(:name => 'body', :page => @emailpage, :content => email_page)
    
    get @url
    assert_select "input[name=to]"
    assert_select "input[name=from]"
    assert_select "input[name=subject]", false
    assert_select "form[method=post]"
    assert_select "form[action=#{@url}]"
  end
  
  def test_form_with_subject
    PagePart.create!(:name => 'body', :page => @emailpage, :content => email_page_with_subject)

    get @url
    assert_select "input[name=to]"
    assert_select "input[name=from]"
    assert_select "input[name=subject][value=the subject]"
    assert_select "form[method=post]"
    assert_select "form[action=#{@url}]"
  end
  
  def test_email_tags
    PagePart.create!(:name => 'email', :page => @emailpage, :content => email_part)

    from = "from@example.com"
    to = ["to@example.com"]
    send_mail(to, from)
    email = ActionMailer::Base.deliveries.pop

    assert email.body.include?(from)
    assert email.body.include?(@full_url)
  end
  
  def test_sends_email
    from = "from@example.com"
    to = ["to@example.com"]
    subject = 'the subject'
    send_mail(to, from, subject)
    @page_to_email.reload
    
    assert 1, ActionMailer::Base.deliveries.size
    assert_equal 1, @page_to_email.emailed_count

    email = ActionMailer::Base.deliveries.pop
    
    assert_equal subject, email.subject
    assert_equal to, email.to
    assert_equal from, email.from.first
    assert email.body.include?(from)
    assert email.body.include?(@full_url)
    assert_redirected_to @page_to_email.url
  end
  
  def send_mail(to=["to@example.com"], from="from@example.com", subject=nil)
    post "/pages/#{@page_to_email.id}/email_page", :to => to, :from => from, :subject => subject    
  end
    
  #view_in_browser(html_document.root)
  def view_in_browser(html)
    File.open('/tmp/integration.html', File::TRUNC|File::CREAT|File::RDWR) do |f|
      f.write html
      `open #{f.path}`
    end    
  end
  
  def email_part
    %(
      <r:email_page>
      <r:from/> thinks <r:page_url/> is an awesome read.
      </r:email_page>
    )
  end
  
  def email_page
    %(
      <r:email_page:form>
        To: <input type="text" name="to"/>
        From: <input type="text" name="from"/>
        <input type="submit">
      </r:email_page:form>
    )
  end

  def email_page_with_subject
    %(
      <r:email_page:form subject="the subject">
        To: <input type="text" name="to"/>
        From: <input type="text" name="from"/>
        <input type="submit">
      </r:email_page:form>
    )
  end
  
  def cool_page
    %(
      <a id="email_page_link" href='<r:email_page:url/>'>email this page</a>
      <div id="count"><r:email_page:count/></div>
    )
  end
    
end