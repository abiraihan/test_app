class CountriesController < ApplicationController

  def show
    @country = Country.find(params[:id])
    @centroids = helpers.get_centroids(@country)
    @geometry_type = helpers.geoms(@country)
  end

  def index
    @countries = Country.all
  end
end
