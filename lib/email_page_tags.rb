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
    result = []
    result << %(<form id='email_page_form' action="/pages/#{tag.locals.page.page_id_to_email}/email_page" method='post'>)
    result <<   %(<input type="hidden" name="subject" value="#{subject}"/>") unless subject.nil? || subject.empty?
    result <<   tag.expand
    result << %(</form>)
    result
  end

  tag 'email_page:url' do |tag|
    %(/pages/#{tag.locals.page.id}/email_page)
  end
  
  tag 'email_page:page_url' do |tag|
    tag.locals.page.last_mail.page_to_email_url
  end
  
  tag 'email_page:from' do |tag|
    tag.locals.page.last_mail.from
  end
end