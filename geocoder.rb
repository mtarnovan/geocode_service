class GeoCoder
  class UnknownIp < StandardError; end
  
  @@retry_count = 0
  
  def self.country_code_from_ip(ip)
    ip = $db.escape(ip)
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
    # connection might have timed out, so try to reconnect
    connect
    @@retry_count += 1
    if @@retry_count < 5
      retry
    else
      puts "Failed after #{@@retry_count} retries:\n #{ex.message}"
      @@retry_count = 0      
    end
  end
  
end