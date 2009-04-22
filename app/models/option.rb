class Option < ActiveRecord::Base

  def is_expired? 
    expired_at and (expired_at <= Time.now)
  end

  def execute
    eval(procedure) unless is_expired? or template
  end

  def color
    return '#ffaaaa' if template
    return 'lightgray' if is_expired?
    'lightblue'
  end

  # ------------------------------------------------------------

  def expire!
    self.expired_at = Time.now
    save!
  end

  def eject
    %x[eject]
  end

end
