uri = URI.parse(ENV["REDISTOGO_URL"] || 'localhost')
$redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
