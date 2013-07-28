class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end
  def index
    @class = Hash.new {|hash, key| hash[key] = ""}
    @all_ratings = ['G', 'PG', 'PG-13', 'R'] 
    if !session.has_key? :index_params
      index_params = {:ratings => @all_ratings}
      @rating_value = Hash.new (true)
      @movies = Movie.all
      session[:index_params] = index_params
      return
    end
    index_params = session[:index_params]
    column  = index_params[:sortby]
    ratings = index_params[:ratings]

    if cur_column = params[:sortby]
      column = cur_column
    end
    if cur_ratings = params[:ratings]
      ratings = cur_ratings.keys
    end

    index_params[:sortby] = column
    index_params[:ratings] = ratings
    @rating_value = Hash.new(false)

    if !cur_column or !cur_ratings
      params[:sortby] = column unless column == nil
      hash_ratings = Hash.new
      ratings.each {|val| hash_ratings[val] = "1" } 
      flash.keep
      params[:ratings] = hash_ratings
      redirect_to movies_path(params)
    end

    options = Hash.new
    if column 
      options[:order] = column 
      @class[column.to_sym] = "hilite"
    end
    if ratings
      options[:conditions] = ["rating IN (?)", ratings]
    end

    ratings.each {|rating| @rating_value[rating] = true}
    @movies = Movie.find(:all , options)
    session[:index_params] = index_params
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(params[:movie])
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
