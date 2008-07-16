class EmailPageMailer < ActionMailer::Base
  def generic_mail(options)
    @recipients = options[:recipients]
    @from = options[:from] || ""
    @cc = options[:cc] || ""
    @bcc = options[:bcc] || ""
    @subject = options[:subject] || ""
    @headers = options[:headers] || {}
    @charset = options[:charset] || "utf-8"
    @content_type = "text/plain"
    @body = options[:body] || ""
  end
end