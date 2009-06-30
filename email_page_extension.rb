class EmailPageExtension < Radiant::Extension
  version "1.0"
  description "Email pages, and keep track of how many times each page was emailed."
  url "http://terralien.com"
  
  define_routes do |map|
    map.resources :email_page, :path_prefix => "/pages/:page_id"
  end
  
  def activate
    EmailPage
    Page.send :include, EmailPageTags
    
    Page.class_eval do
      def update_emailed_count
        Page.increment_counter("emailed_count", id)
        clear_cache
      end
    end
  end
  
  def deactivate
  end
  
end