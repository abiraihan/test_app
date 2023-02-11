module CountriesHelper
  def get_name(division)
    division.name
  end

  def get_centroids(division)
    division.geom.centroid
  end

  def geoms(division)
    division.geom.geometry_type
  end
end
