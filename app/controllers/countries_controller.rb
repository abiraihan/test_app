class CountriesController < ApplicationController

  def show
    @country = Country.find(params[:id])
    @centroids = helpers.get_centroids(@country)
    @geometry_type = helpers.geoms(@country)
    @district = District.where(country_id: @country.id).select('districts').map { |f| f['districts']}
    @district_size = @district.size
  end

  def index
    @countries = Country.all
  end
end
