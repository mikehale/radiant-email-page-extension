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
  
  desc %{
    Will expand if and only if there is an error with the last mail.

    If you specify the "on" attribute, it will only expand if there
    is an error on the named attribute, and will make the error
    message available to the mailer:error:message tag.}
  tag "email_page:error" do |tag|
    if mail = tag.locals.page.last_mail
      if on = tag.attr['on']
        if error = mail.errors[on]
          tag.locals.error_message = error
          tag.expand
        end
      else
        if !mail.valid?
          tag.expand
        end
      end
    end
  end

  desc %{Outputs the error message.}
  tag "email_page:error:message" do |tag|
    tag.locals.error_message
  end
  
end