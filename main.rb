require './k_means'

f = File.open("prob/data.txt", "r")

data = []
f.each_line do |line|
  x, y = line.split(",")
  data << [x.to_f, y.to_f]
end

foutk = File.open("log/k.txt", "w")
foutk.puts "k,between,within,var"

(2..6).each do |k|
  puts "#{k} processing.."

  km        = KMeans.new(data)
  clusters  = km.run(k)


  fout = File.open("log/out_#{k}.txt", "w")
  fout.puts "dopamina,adrenalina,classe"
  clusters.each do  |k, data_k|
    data_k.each do |d|
      fout.puts "#{d[0]}, #{d[1]}, #{k}"
    end
  end

  foutk.puts "#{k}, #{km.var_between_cluster}, #{km.var_within_cluster}, #{km.variance}"   
end

