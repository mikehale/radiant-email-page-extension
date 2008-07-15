module EmailPageTags
  include Radiant::Taggable
  
  tag 'email_page' do |tag|
    tag.expand
  end
  
  tag 'email_page:count' do |tag|
    tag.locals.page.emailed_count
  end
  
  tag 'email_page:form' do |tag|
    subject = tag.attr["subject"]
    email_page = Page.find_by_title('Email Page')
    %(<form id='email_page_form' action="/pages/#{email_page.page_id_to_email}/email_page" method='post'>
        <input type="hidden" name="subject" value="#{subject}"/>
        #{tag.expand}
      </form>)
  end

  tag 'email_page:url' do |tag|
    %(/pages/#{tag.locals.page.id}/email_page)
  end
  
end