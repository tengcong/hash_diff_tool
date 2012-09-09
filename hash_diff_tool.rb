class Object
  def try(*a, &b)
    if a.empty? && block_given?
      yield self
    else
      public_send(*a, &b) if respond_to?(a.first)
    end
  end
end

class Nil
  def try(*args)
    nil
  end
end

def diff_hash apple, peach, diff_info
  diff_attr apple, peach, diff_info
  diff_embeded_attr apple, peach, diff_info
end

def diff_embeded_attr apple, peach, diff_info

  apple_hash_keys = apple.select{|k, v| Hash === v}.keys
  peach_hash_keys = peach.select{|k, v| Hash === v}.keys


  if apple_hash_keys && peach_hash_keys
    same_key = apple_hash_keys & peach_hash_keys
    same_key.try(:each) do |k|
      diff_info[k] = Hash.new do |hash, key|
        hash[key] = {}
      end
      diff_attr apple[k], peach[k], diff_info[k]
    end
  end
end

def diff_attr apple, peach, diff_info
  greater_attr = (apple.try(:keys) - peach.try(:keys))
  less_attr = (peach.try(:keys) - apple.try(:keys))

  greater_attr.each do |e|
    diff_info[:with][e] = apple[e]
  end

  less_attr.each do |e|
    diff_info[:without][e] = peach[e]
  end

  diff_value apple, peach, diff_info
end


def diff_value apple, peach, diff_info
  share_attrs = apple.try(:keys) & peach.try(:keys)
  share_attrs.each do |attr|
    diff_info[attr][:from] = apple[attr]
    diff_info[attr][:to] = peach[attr]

    if (Hash === apple[attr] && Hash === peach[attr])
      diff_info[attr] = Hash.new do |hash, key|
        hash[key] = {}
      end
      diff_hash apple[attr], peach[attr], diff_info[attr]
    end
  end
end

diff_info = Hash.new do |hash, key|
  hash[key] = {}
end

apple = {:a => 1, :f => {:m => 2, :g => 4, :h => {:n => 3}}, :g => {:k => 1}}
peach = {:a => 2, :b => 3, :f => {:m => 1, :y => 123, :h => {:n => 4, :x => 1}}, :x => 1, :n => 123}

p apple
p peach
p '-' * 10
diff_hash apple, peach, diff_info
p diff_info
