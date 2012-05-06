require "json"

class DatabaseController < ApplicationController
  skip_filter :redirector
  
  def database
    @results = User.all
    
    respond_to do |format|      
      format.csv  # show.csv.erb
    end
  end

end
