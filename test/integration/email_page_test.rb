require File.dirname(__FILE__) + '/../test_helper'

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
                     
    @url = "/pages/#{@page_to_email.id}/email_page"

    @emailpage = Page.create!(:title => 'Email', 
                             :slug => 'email', 
                             :breadcrumb => 'email', 
                             :status => Status[:published], 
                             :parent => @home, 
                             :class_name => "EmailPage")
                             
    # PagePart.create!(:name => 'body', :page => @emailpage, :content => email_page_with_subject)
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
  
  def test_sends_email
    from = "fred@us.com"
    to = ["bob@us.com"]
    
    post "/pages/#{@page_to_email.id}/email_page", :to => to, :from => from, :subject => 'the subject'
    @page_to_email.reload
    assert 1, ActionMailer::Base.deliveries.size
    assert_equal 1, @page_to_email.emailed_count

    email = ActionMailer::Base.deliveries.pop
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