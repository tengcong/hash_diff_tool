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
  if Hash === apple && Hash === peach
    diff_attr apple, peach, diff_info
    diff_arr_attr apple, peach, diff_info
    diff_embeded_attr apple, peach, diff_info
  end
end


def diff_arr_attr apple, peach, diff_info
  apple_arr_keys = apple.select{|k, v| Array === v}.try(:keys)
  peach_arr_keys = peach.select{|k, v| Array === v}.try(:keys)

  unless apple_arr_keys.try(:empty?) && peach_arr_keys.try(:empty?)
    diff_attr apple, peach, diff_info
  end

  same_key_arr = apple_arr_keys & peach_arr_keys
  same_key_arr.try(:each) do |k|
    if apple[k] == peach[k]
      next
    else
      diff_info[k] = Hash.new do |hash, key|
        hash[key] = {}
      end

      apple_size = apple[k].size
      peach_size = peach[k].size

      if apple_size == peach_size
        apple_size.times do |t|
          # can not just compare hash, there can be common attrs, arrays, hashes
          # should compare different types
          #diff_hash apple[k][t], peach[k][t], diff_info[k]
        end
        next
      end
      diff_info[k][:size][:from] = apple_size
      diff_info[k][:size][:to] = peach_size

      if apple_size > peach_size
        diff_info[k][:with] = apple[k][(peach_size - apple_size) .. -1]
        peach_size.times do |t|
          #diff_hash apple[k][t], peach[k][t], diff_info[k]
        end
      else
        diff_info[k][:without] = peach[k][(apple_size - peach_size) .. -1]
        apple_size.times do |t|
          #diff_hash apple[k][t], peach[k][t], diff_info[k]
        end
      end

      #deleted_code
    end

  end
end

def deleted_code
    apple_hash_values = apple[k].select{|e| Hash === e}
    apple_arr_values = apple[k].select{|e| Array === e}.flatten
    apple_common_values = apple[k] - apple_hash_values - apple_arr_values

    peach_hash_values = peach[k].select{|e| Hash === e}
    peach_arr_values = peach[k].select{|e| Array === e}.flatten
    peach_common_values = peach[k] - peach_hash_values - peach_arr_values


    diff_common_array apple_common_values, peach_common_values, diff_info[k]
    diff_arr_attr convert_arr_to_hash(apple_arr_values),
                  convert_arr_to_hash(peach_arr_values),
                  diff_info[k]


    p apple_hash_values
    p peach_hash_values
    diff_embeded_attr apple_hash_values, peach_hash_values, diff_info[k]
end

def convert_arr_to_hash arr
  result = {}
  arr.each_with_index do |e, index|
    result.tap{|s| s[index] = e}
  end
  result
end


def diff_common_array apple_arr, peach_arr, diff_info
  greater_values = apple_arr - peach_arr
  less_values = peach_arr - apple_arr

  unless greater_values == [] || less_values == []
    diff_info[:with] = greater_values
    diff_info[:without] = less_values
  end
end

def diff_embeded_attr apple, peach, diff_info
  apple_hash_keys = apple.select{|k, v| Hash === v}.try(:keys)
  peach_hash_keys = peach.select{|k, v| Hash === v}.try(:keys)

  same_key = apple_hash_keys & peach_hash_keys
  same_key.try(:each) do |k|
    if apple[k] ==  peach[k]
      next
    end
    diff_info[k] = Hash.new do |hash, key|
      hash[key] = {}
    end
    diff_attr apple[k], peach[k], diff_info[k]
  end
end

def diff_attr apple, peach, diff_info
  greater_attr = (apple.try(:keys) - peach.try(:keys))
  less_attr = (peach.try(:keys) - apple.try(:keys))

  greater_attr.each do |e|
    diff_info[:with][e] = apple[e]
  end

  less_attr.each do |e|
    diff_info[:without] << peach[e]
  end

  diff_value apple, peach, diff_info
end


def diff_value apple, peach, diff_info
  share_attrs = apple.try(:keys) & peach.try(:keys)

  share_attrs.each do |attr|
    if apple[attr] != peach[attr]
      diff_info[attr][:from] = apple[attr]
      diff_info[attr][:to] = peach[attr]
    end

    if (Hash === apple[attr] && Hash === peach[attr])
      if apple[attr] == peach[attr]
        next
      end
      diff_info[attr] = Hash.new do |hash, key|
        hash[key] = {}
      end
      #diff_hash apple[attr], peach[attr], diff_info[attr]
      diff_embeded_attr apple[attr], peach[attr], diff_info[attr]
    end

  end
end

diff_info = Hash.new do |hash, key|
  hash[key] = {}
end

peach = {"maxAge"=>60000,
 "active"=>true,
 "_uuid"=>"tmu",
 "className"=>
  "com.yottaa.platform.router.backplane.adn.ApplicationDeliveryNetwork",
 "need_https"=>false,
 "timeStamp"=>1343295202876,
 "loadBalancers"=>
  [{"_id"=>"loadbalancer_1",
    "members"=>
     [{"idref"=>"0431af298aa4"},
      {"idref"=>"0131b848ed47"},
      {"idref"=>"0231ccec8654"},
      {"idref"=>"03312e33be29"}],
    "ipAddress"=>"",
    "sessionCookie"=>"cookie",
    "region"=>"",
    "loadBalanceStrategy"=>
     {"qualifier"=>{},
      "_id"=>"500f9f261072c64c6d000069",
      "type"=>"geoproximity"},
    "datacenter"=>"",
    "removed_members"=>[],
    "hostName"=>""}],
 "security"=>nil,
 "keyStore"=>{},
 "optimization_template"=>"best",
 "private_test"=>false,
 "optimizations"=>nil,
 "https_enabled"=>false,
 "protocol_version"=>"",
 "sslAdn"=>false,
 "actions"=>nil,
 "protocolVersion"=>"1.0",
 "activation_7_days_mail_sended"=>false,
 "activation_14_days_mail_sended"=>false,
 "ttl"=>60,
 "trial_7_days_mail_sended"=>false,
 "version"=>"1",
 "customRules"=>[],
 "isDeleted"=>false,
 "userID"=>nil,
 "new_adn"=>false,
 "domainNames"=>
  [{"active"=>true,
    "activatable"=>false,
    "_id"=>"500f9f261072c64c6d000068",
    "yottaaCNAME"=>"system.topology.tmu.yottaa.net",
    "refSystemAdn"=>"system",
    "role"=>"domain",
    "domain"=>"yottaa.net",
    "target"=>{"idref"=>"loadbalancer"},
    "hostName"=>"system.topology.tmu",
    "dns_record_ids"=>[]}],
 "originServers"=>
  [{"latitude"=>1.28872494079436,
    "_id"=>"0431af298aa4",
    "ipAddress"=>"175.41.138.164",
    "portNumber"=>80,
    "region"=>"SINGAPORE",
    "maxConnection"=>1000,
    "readTimeout"=>100,
    "provider"=>"aws",
    "longitude"=>103.850069046021,
    "sslPort"=>443,
    "datacenter"=>"ap-southeast",
    "hostName"=>"ns-ap-southeast.yottaa.net",
    "connectionTimeout"=>20,
    "country"=>"SG"},
   {"latitude"=>37.3788878500453,
    "_id"=>"0131b848ed47",
    "ipAddress"=>"184.72.237.71",
    "portNumber"=>80,
    "region"=>"VIRGINIA",
    "maxConnection"=>1000,
    "readTimeout"=>100,
    "provider"=>"aws",
    "longitude"=>-78.673095703125,
    "sslPort"=>443,
    "datacenter"=>"us-east",
    "hostName"=>"ns-us-east.yottaa.net",
    "connectionTimeout"=>20,
    "country"=>"US"},
   {"latitude"=>36.8268747428773,
    "_id"=>"0231ccec8654",
    "ipAddress"=>"204.236.134.84",
    "portNumber"=>80,
    "region"=>"CALIFORNIA",
    "maxConnection"=>1000,
    "readTimeout"=>100,
    "provider"=>"aws",
    "longitude"=>-119.454345703125,
    "sslPort"=>443,
    "datacenter"=>"us-west",
    "hostName"=>"ns-us-west.yottaa.net",
    "connectionTimeout"=>20,
    "country"=>"US"},
   {"latitude"=>53.4357192066942,
    "_id"=>"03312e33be29",
    "ipAddress"=>"46.51.190.41",
    "portNumber"=>80,
    "region"=>"DUBLIN",
    "maxConnection"=>1000,
    "readTimeout"=>100,
    "provider"=>"aws",
    "longitude"=>-8.23974609375,
    "sslPort"=>443,
    "datacenter"=>"eu-west",
    "hostName"=>"ns-eu-west.yottaa.net",
    "connectionTimeout"=>20,
    "country"=>"IE"}],
 "site_id"=>nil,
 "type"=>2,
 "change_log"=>{}}




apple = {"maxAge"=>60000,
 "active"=>true,
 "_uuid"=>"tmu",
 "className"=>
  "com.yottaa.platform.router.backplane.adn.ApplicationDeliveryNetwork",
 "need_https"=>false,
 "timeStamp"=>1343295202876,
 "loadBalancers"=>
  [{"_id"=>"loadbalancer",
    "members"=>
     [{"idref"=>"0431af298aa4"},
      {"idref"=>"1131b848ed47"},
      {"idref"=>"0231ccec8654"},
      {"idref"=>"03312e33be29"}],
    "ipAddress"=>"",
    "sessionCookie"=>"cookie",
    "region"=>"",
    "loadBalanceStrategy"=>
     {"qualifier"=>{},
      "_id"=>"500f9f261072c64c6d000069",
      "type"=>"geoproximity"},
    "datacenter"=>"",
    "removed_members"=>[],
    "hostName"=>""}],
 "security"=>nil,
 "keyStore"=>{},
 "optimization_template"=>"best",
 "private_test"=>false,
 "optimizations"=>nil,
 "https_enabled"=>false,
 "protocol_version"=>"",
 "sslAdn"=>false,
 "actions"=>nil,
 "protocolVersion"=>"1.0",
 "activation_7_days_mail_sended"=>false,
 "activation_14_days_mail_sended"=>false,
 "ttl"=>60,
 "trial_7_days_mail_sended"=>false,
 "version"=>"1",
 "customRules"=>[],
 "isDeleted"=>false,
 "userID"=>nil,
 "new_adn"=>false,
 "domainNames"=>
  [{"active"=>true,
    "activatable"=>false,
    "_id"=>"500f9f261072c64c6d000068",
    "yottaaCNAME"=>"system.topology.tmu.yottaa.net",
    "refSystemAdn"=>"system",
    "role"=>"domain",
    "domain"=>"yottaa.net",
    "target"=>{"idref"=>"loadbalancer"},
    "hostName"=>"system.topology.tmu",
    "dns_record_ids"=>[]}],
 "originServers"=>
  [{"latitude"=>1.28872494079436,
    "_id"=>"0431af298aa4",
    "ipAddress"=>"175.41.138.164",
    "portNumber"=>80,
    "region"=>"SINGAPORE",
    "maxConnection"=>1000,
    "readTimeout"=>100,
    "provider"=>"aws",
    "longitude"=>103.850069046021,
    "sslPort"=>443,
    "datacenter"=>"ap-southeast",
    "hostName"=>"ns-ap-southeast.yottaa.net",
    "connectionTimeout"=>20,
    "country"=>"SG"},
   {"latitude"=>37.3788878500453,
    "_id"=>"0131b848ed47",
    "ipAddress"=>"184.72.237.71",
    "portNumber"=>80,
    "region"=>"VIRGINIA",
    "maxConnection"=>1000,
    "readTimeout"=>100,
    "provider"=>"aws",
    "longitude"=>-78.673095703125,
    "sslPort"=>443,
    "datacenter"=>"us-east",
    "hostName"=>"ns-us-east.yottaa.net",
    "connectionTimeout"=>20,
    "country"=>"US"},
   {"latitude"=>36.8268747428773,
    "_id"=>"0231ccec8654",
    "ipAddress"=>"204.236.134.84",
    "portNumber"=>80,
    "region"=>"CALIFORNIA",
    "maxConnection"=>1000,
    "readTimeout"=>100,
    "provider"=>"aws",
    "longitude"=>-119.454345703125,
    "sslPort"=>443,
    "datacenter"=>"us-west",
    "hostName"=>"ns-us-west.yottaa.net",
    "connectionTimeout"=>20,
    "country"=>"US"},
   {"latitude"=>53.4357192066942,
    "_id"=>"03312e33be29",
    "ipAddress"=>"46.51.190.41",
    "portNumber"=>80,
    "region"=>"DUBLIN",
    "maxConnection"=>1000,
    "readTimeout"=>100,
    "provider"=>"aws",
    "longitude"=>-8.23974609375,
    "sslPort"=>443,
    "datacenter"=>"eu-west",
    "hostName"=>"ns-eu-west.yottaa.net",
    "connectionTimeout"=>20,
    "country"=>"IE"}],
 "site_id"=>nil,
 "type"=>2,
 "change_log"=>{}}

# apple = {:z => [{:m => 1},[1,2,3, [1,2,3]], {:x => 3}, 3, 1], :a => 1, :f => {:m => 2, :g => 4, :h => {:n => 3}}, :g => {:k => 1}}
# peach = {:z => [1, 2, [1,2,4, [2,3,4,5]]], :a => 2, :b => 3, :f => {:m => 1, :y => 123, :h => {:n => 4, :x => 1}}, :x => 1, :n => 123}
 #peach = {:a => 1}
  #
#apple = {:c => 2, :a => [4,2,[3,2],[5,2,[0]], {:b => 5}, {:c => [6,7,8]}]}
#peach = {:c => 3, :a => [1,2,[3,2,[1]],[2], {:c => 5}, {:c => [2,7,1]}]}
apple = {
  :a => [
    { :b => 1, :c => 2},
    { :e => [2]}
  ]
}
peach = {
  :a => [
    { :b => 1, :c => 2},
    { :c => 1, :d => 2},
    { :e => [1,2,3]}
  ]
}

p apple
p peach
p '-' * 10
diff_hash apple, peach, diff_info
p diff_info
