require File.dirname(__FILE__) + '/../test_helper'

class EmailPageTest < ActionController::IntegrationTest
  def setup
    @home = Page.create!(:title => 'Home', :slug => '/', :breadcrumb => 'home', :status => Status[:published])
    @page_to_email = Page.create!(:title => 'Cool Page', :slug => 'cool', :breadcrumb => 'cool', :status => Status[:published], :parent => @home)
    @emailpage = Page.create!(:title => 'Email Page', :slug => 'email', :breadcrumb => 'email', :status => Status[:published], :parent => @home)

    PagePart.create!(:name => 'body', :page => @page_to_email, :content => cool_page)
    PagePart.create!(:name => 'body', :page => @emailpage, :content => email_page)
  end
  
  def test_link
    get '/cool'
    assert_select "a[href=/pages/#{@page_to_email.id}/email_page]"
  end
  
  def test_count
    @page_to_email.emailed_count = 999999
    @page_to_email.save
    get '/cool'
    assert_select "#count", "999999"
  end
  
  def test_form
    get '/email'
    assert_select "input[name=to]"
    assert_select "input[name=from]"
    assert_select "input[name=subject][value=the subject]"
  end
  
  def test_sends_email
    from = "fred@us.com"
    to = ["bob@us.com"]
    
    post "/pages/#{@page_to_email.id}/email_page", :to => to, :from => from, :subject => 'the subject'
    @page_to_email.reload
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_equal 1, @page_to_email.emailed_count

    email = ActionMailer::Base.deliveries[0]
    full_url = "#{request.protocol}#{request.domain}#{@page_to_email.url}"
    
    assert_equal "the subject", email.subject
    assert_equal to, email.to
    assert_equal from, email.from.first
    assert_equal %(#{from} enjoyed reading this page #{full_url} and thinks you might too.), email.body
    assert_redirected_to @page_to_email.url
  end
  
  #view_in_browser(html_document.root)
  def view_in_browser(html)
    File.open('/tmp/integration.html', File::TRUNC|File::CREAT|File::RDWR) do |f|
      f.write html
      `open #{f.path}`
    end    
  end
  
  def email_page
    %(<r:email_page:form subject="the subject"/>)
  end
  
  def cool_page
    %(
      <a id="email_page_link" href='<r:email_page:url/>'/>
      <div id="count"><r:email_page:count/></div>
    )
  end
    
end