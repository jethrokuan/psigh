class SgHaze < Sinatra::Base
  def current_time
    hour = Time.now.hour
    if hour < 12
      if hour == 0
        current_time = "12AM"
      else
        current_time = "#{hour}AM"
      end
    else
      current_time="#{hour-12}PM"
    end
  end
  def hourly_data
    original_data = data().to_a
    new_data = Hash.new
    original_data.each_with_index do |a,index|
      if index == 0
        new_data["12AM"] = original_data[0][1]
      elsif index == 1
        new_data["1AM"] = original_data[1][1]
      end
      if index > 1
        if original_data[index][1] == "-"
          new_data[original_data[index][0]] = "-"
        else
          new_data[original_data[index][0]] = (3*original_data[index][1].to_i-original_data[index-1][1].to_i-original_data[index-2][1].to_i).to_s
        end
      end
    end
    return new_data
  end

  def data
    doc = Nokogiri::HTML(open('http://app2.nea.gov.sg/anti-pollution-radiation-protection/air-pollution/psi/psi-and-pm2-5-readings'))
    node = doc.at_css('div.c1 >div >table')
    arr = Array.new
    [1,2,3,4].each do |num|
      node.xpath("tr[#{num}]").children.each do |a|
        arr << a.content
      end
    end
    arr.each do |a|
      a.gsub!(/\s/,"")
    end
    arr.reject!{|a| a.empty?}
    hash_data=Hash.new
    [[1,14],[2,15],[3,16],[4,17],[5,18],[6,19],[7,20],[8,21],[9,22],[10,23],[11,24],[12,25],[27,40],[28,41],[29,42],[30,43],[31,44],[32,45],[33,46],[34,47],[35,48],[36,49],[37,50],[38,51]].each do |a|
      hash_data[arr[a[0]]] = arr[a[1]]
    end
    return hash_data
  end
  
  def current_reading
    current = data()
    return current[current_time()]
  end
  get '/' do
    @current_reading = current_reading()
    @hourly_data = hourly_data()
    @three_hour_data = data()
    erb :index
  end

  get '/json' do
    return data().to_json
  end

  get '/hourly' do
    return hourly_data().to_json
  end
end
