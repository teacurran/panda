module Merb
  module GlobalHelpers
    def nav_item(name, url=nil)
      if url.class == Hash
        url_str = '/'+url[:controller].to_s
        url_str += '/'+url[:action].to_s if url.include?(:action)
        url_str += '/'+url[:actions].first.to_s if url.include?(:actions) and url[:actions].first.to_s != "index"
      elsif url.class == String
        url_str = url
      end
      %(<li><a href="#{url ? url_str : '/'+name}">#{name.humanize}</a></li>)
    end
    
    def notice
      %(<div class="notice">#{@notice}</div>) if @notice
    end
    
    def message
      %(<div class="notice">#{request.message[:notice]}</div>) if request.message[:notice]
    end

    def javascript_include_tag(*names)
      names.inject('') do |tag,name|
        stamp = File.mtime("public/javascripts/#{name}.js").to_i
        tag << "<script type=\"text/javascript\" charset=\"utf-8\" src=\"/javascripts/#{name}.js?#{stamp}\"></script>\n"
      end
    end
  end
end    