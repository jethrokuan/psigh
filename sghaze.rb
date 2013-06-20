class SgHaze < Sinatra::Base
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
  get '/' do
    @hash_data = data()
    erb :index
  end

  get '/json' do
    return data().to_json
  end
end
