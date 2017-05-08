require './k_means'

f = File.open("prob/data.txt", "r")

data = []
f.each_line do |line|
  x, y = line.split(",")
  data << [x.to_f, y.to_f]
end

[2, 3, 4, 5].each do |k|
  km        = KMeans.new(data)
  clusters  = km.run(k)


  fout = File.open("out_#{k}.txt", "w")
  fout.puts "dopamina,adrenalina,classe"
  clusters.each do  |k, data_k|
    data_k.each do |d|
      fout.puts "#{d[0]}, #{d[1]}, #{k}"
    end
  end
end

