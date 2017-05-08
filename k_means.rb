#used for mean, standard deviation, etc.
require 'descriptive_statistics'

class KMeans

  attr_reader :dataset, :dataset_normalized, :means_point, :cluster

  MIN  = 0
  MAX  = 1
  MEAN = 2
  SD   = 3 
  VAR  = 4
  SUM  = 5

  # dataset = [
  #     [feature1, feature2, feature3, ..., featureN],
  #     [feature1, feature2, feature3, ..., featureN],
  #     [feature1, feature2, feature3, ..., featureN],
  #   ]
  def initialize(dataset = [], options = {})
    @dataset            = dataset
    @dataset_normalized = []

    @normalization      = options[:normalization] || :none # linear or standard_deviation

    normalize()
  end

  def run(k, ephocs = 300)
    @means_point = rand_means_point(k)
    @cluster     = {}

    ephocs.times do |e|

      k.times.each{|k| @cluster[k] = []}

      @dataset_normalized.each_with_index do |data, i|
        dists = k.times.collect{|ki| distance(@means_point[ki], data)}
        ck    = dists.index(dists.min)
        @cluster[ck] << data
      end

      new_means_point = get_means_point(@cluster)

      if new_means_point == @means_point
        @means_point = new_means_point
        break
      else
        @means_point = new_means_point
      end
    end

    @cluster
  end  

  # Return the variance within clustes
  def var_within_cluster

    total_var = 0
    @cluster.each do |k, data|
      dists = data.collect{|d| distance(@means_point[k], d)**2}
      var   = (dists.sum*1.0)/(data.size)

      prob  = (data.size*1.0)/@dataset_normalized.size
      total_var += (var * prob)
    end

    total_var
  end

  # Return the variance between clustes
  def var_between_cluster
    var = 0
    
    # Master Mean point 
    master_mean_point = []
    count_features.times do |t|
      features_of_cluster = @means_point.collect{|d| d[t]}
      master_mean_point << features_of_cluster.mean
    end

    # Variance
    k = -1
    dists     = @means_point.collect{|point| k+=1; @cluster[k].size*distance(master_mean_point, point)**2}
    var       = ((dists.sum*1.0)/@means_point.size)

    var
  end

  # Maximize Variance between cluster and Minimize with cluster
  def variance
    (var_between_cluster*1.0/var_within_cluster)
  end

  # Returns the distance of the characteristics between two objects
  # default: euclidian
  def distance(features1, features2, type = :euclidian)
    sum = 0

    count_features.times do |i|
      sum += (features1[i] - features2[i])**2
    end

    Math::sqrt(sum)
  end

  def count_features
    @dataset.first.size
  end

  private 

  # Normalize dataset 
  def normalize()
    @dataset.each do |features|
      feature_normalized = get_features_normalized(features)
      @dataset_normalized << feature_normalized
    end
  end

  def get_features_normalized(features)
    case @normalization
      when :linear
        normalize_linear(features)
      when :standard_deviation
        normalize_sd(features)
      when :none
        features
      else
        raise "Normalization not found"
      end
  end
  
  # Normalize dataset with a Normalization by Linear
  def normalize_linear(features)
    # [min, max, mean, sd]
    statistics = get_statistics_of_features
    n_features = []

    count_features.times do |fi|
      min, max, mean, sd = statistics[fi]
      n_features[fi] = (features[fi]-min).to_f/(max-min)
    end

    n_features
  end

  # Normalize dataset with a Normalization by standard deviation 
  def normalize_sd(features)
    # [min, max, mean, sd]
    statistics = get_statistics_of_features
    n_features = []
    
    count_features.times do |fi|
      min, max, mean, sd = statistics[fi]
      n_features[fi] = (features[fi]-mean).to_f/(sd)
    end

    n_features
  end

  # Return the statistics of all features (min, max, mean, sd)
  def get_statistics_of_features
    return  @statistics if  not @statistics.nil?

    # Statistics of features (min, max, mean, sd)
    @statistics  = []

    count_features.times do |i|
      f_min, f_max, f_mean, f_std = statistics_of_features(i)

      @statistics[i] = [f_min, f_max, f_mean, f_std]
    end

    @statistics
  end

  # Return the statistics of feature (min, max, mean, sd, var, sum)
  def statistics_of_features(index)

    features = @dataset.collect{|d| d[index]}

    #statistical properties of the feature set
    f_std  = features.standard_deviation
    f_mean = features.mean
    f_min  = features.min
    f_max  = features.max
    f_var  = features.variance    
    f_sum  = features.sum

    return [f_min, f_max, f_mean, f_std, f_var, f_sum]
  end  

  def rand_means_point(k)
    points     = []
    statistics = get_statistics_of_features

    k.times do |i|
      point = count_features.times.collect{|t| rand_point(t)}

      redo if points.include? point

      points << point
    end

    points
  end

  def get_means_point(cluster)
    points  = []

    cluster.each do |k, _dataset|
      point = []
        
      if _dataset.empty?
        point = count_features.times.collect{|t| rand_point(t)}
      else
        count_features.times do |t|
          features_of_cluster = _dataset.collect{|d| d[t]}
          point << features_of_cluster.mean
        end
      end

      points << point
    end

    points
  end

  def rand_point(f)
    statistics = get_statistics_of_features
    rand(statistics[f][MIN]..statistics[f][MAX])+rand
  end
end


# km = KMeans.new([
#       [feature1, feature2, feature3, ..., featureN],
#       [feature1, feature2, feature3, ..., featureN]
#     ])
# 
# km.run(K)


