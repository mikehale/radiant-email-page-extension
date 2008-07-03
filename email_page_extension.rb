class EmailPageExtension < Radiant::Extension
  version "1.0"
  description "Email pages, and keep track of how many times each page was emailed."
  url "http://terralien.com"
  
  define_routes do |map|
    map.resources :email_page, :path_prefix => "/pages/:page_id"
  end
  
  def activate
    Page.send :include, EmailPageTags
    
    Page.class_eval do
      attr_accessor :page_id_to_email
      
      def update_emailed_count
        self.emailed_count = self.emailed_count + 1
        self.save!
        ResponseCache.instance.expire_response(url)
      end
    end
  end
  
  def deactivate
  end
  
end