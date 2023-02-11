module CountriesHelper
  def get_name(city)
    city.name
  end

  def get_centroids(city)
    city.geom.centroid
  end

  def geoms(obj)
    obj.geom.geometry_type
  end
end
