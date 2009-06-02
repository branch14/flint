class Option < ActiveRecord::Base

  def is_expired? 
    expired_at and (expired_at <= Time.now)
  end

  def execute(prefix='')
    eval(prefix+"\n"+procedure) unless is_expired?
  end

  def color
    return '#ffaaaa' if template
    return 'lightgray' if is_expired?
    'lightblue'
  end

  def expire!
    self.expired_at = Time.now
    save!
  end

  def activate!
    self.expired_at = nil
    save!
  end

end
