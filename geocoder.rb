class GeoCoder
  class UnknownIp < StandardError; end
  
  COUNTRY_CODE_TO_LANG = {
    :at => :de,
    :de => :de,
    :ch => :de,
    :ro => :ro,
    :md => :ro
  }
  
  @@retry_count = 0
  
  def self.country_code_from_ip(ip)
    res = $db.query <<-EOS, :as => :array
      SELECT country_code
      FROM ip_country
      WHERE MBRCONTAINS(ip_poly, 
        POINTFROMWKB(
          POINT(INET_ATON('#{ip}'), 0)
        )
      )
    EOS
    res.first
  rescue Mysql2::Error => ex
    connect
    @@retry_count += 1
    if @@retry_count < 5
      retry
    else
      puts "Failed after #{@@retry_count} retries #{ex.message}"
      @@retry_count = 0      
    end
  end
  
  def self.lang_from_ip(ip, fallback_lang = :en)
    COUNTRY_CODE_TO_LANG[country_code_from_ip(ip).downcase.to_sym] || fallback_lang
  rescue UnknownIp
    #Rails.logger.warn "Could not geolocate IP: #{ip}"
    fallback_lang
  end
end