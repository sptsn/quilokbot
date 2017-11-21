module Telegram::Redis

  protected

  def set_redis(value)
    $redis.set @resident.telegram_id, value.to_json
  end

  def reset_redis
    $redis.del @resident.telegram_id
  end

  def redis_value
    JSON.parse $redis.get @resident.telegram_id
  end

end
