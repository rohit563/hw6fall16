class Movie < ActiveRecord::Base
  def self.all_ratings
    %w(G PG PG-13 NC-17 R)
  end
  
class Movie::InvalidKeyError < StandardError ; end

 def self.find_in_tmdb(string)
   begin
   Tmdb::Api.key("f4702b08c0ac6ea5b51425788bb26562")
   rescue Tmdb::InvalidApiKeyError
       raise Movie::InvalidKeyError, 'Invalid API key'
   end
    @search = Tmdb::Search.new 
    @search.resource('movie')
    @search.query(string)
    @matching_movies = @search.fetch 
    movie_arr = []
      @matching_movies.each do |movie|
         releases = Tmdb::Movie.releases(movie['id'])
         country_releases = releases['countries']
         us_release = country_releases.select {|release| release['iso_3166_1'] == 'US'}
         if !us_release.blank? && !us_release[0]['certification'].blank? 
           rating = us_release[0]['certification'] 
         else
           rating = 'N/A'
         end
         if movie['release_date'].blank?
           release_date = 'TBD'
         else
           release_date = movie['release_date']
         end
         
         movie_hash = {:tmdb_id => movie['id'], :rating => rating, :title => movie['title'], :release_date => release_date, :overview => movie['overview']}
         movie_arr << movie_hash
     end
     movie_arr
  end
  
  def self.add_movies(movie_id)
    movie = Tmdb::Movie.detail(movie_id)
    title = movie['original_title']
    release_date = movie['release_date']
    releases = Tmdb::Movie.releases(movie_id)


    country_releases = releases['countries'] 
    us_release = country_releases.select {|release| release['iso_3166_1'] == 'US'}
    if !us_release.blank? 
      rating = us_release[0]['certification'] 
    else
      rating = 'N/A'
    end
    movie_params = {:title => title, :release_date => release_date, :rating => rating}
    Movie.create!(movie_params)
  end
end