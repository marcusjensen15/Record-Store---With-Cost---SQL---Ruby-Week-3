#!/usr/bin/env ruby
require('sinatra')
require('sinatra/reloader')
require('./lib/album')
require('./lib/song')
require('./lib/artist')
require('pry')
require('pg')
also_reload('lib/**/*.rb')

DB = PG.connect({:dbname => "record_store"})

# Get the detail for a specific song such as lyrics and songwriters.
get('/albums/:id/songs/:song_id') do
  @song = Song.find(params[:song_id].to_i())
  erb(:song)
end

# Post a new song. After the song is added, Sinatra will route to the view for the album the song belongs to.
post('/albums/:id/songs') do
  @album = Album.find(params[:id].to_i())
  song = Song.new(params[:song_name], @album.id, nil)
  song.save()
  erb(:album)
end

# Edit a song and then route back to the album view.
patch('/albums/:id/songs/:song_id') do
  @album = Album.find(params[:id].to_i())
  song = Song.find(params[:song_id].to_i())
  song.update(params[:name], @album.id)
  erb(:album)
end

# Delete a song and then route back to the album view.
delete('/albums/:id/songs/:song_id') do
  song = Song.find(params[:song_id].to_i())
  song.delete
  @album = Album.find(params[:id].to_i())
  erb(:album)
end

# This will be our home page. '/' is always the root route in a Sinatra application.
get('/') do
  @albums = Album.all
  erb(:albums)
end

# This route will show a list of all albums.
get('/albums') do
  if params["search"]
    @albums = Album.search_name(params[:search])
  elsif params["alphabetize"]
    @albums = Album.alphabetize
  elsif params["sort_cost"]
    @albums = Album.sort_cost
  elsif params["sort_year"]
    @albums = Album.sort_year
  elsif params["random"]
    @albums = Album.random
  else
    @albums = Album.all
  end
  erb(:albums)
end

# This will take us to a page with a form for adding a new album.
get('/albums/new') do
  erb(:new_album)
end

# This route will add an album to our list of albums. We can't access this by typing in the URL. In a future lesson, we will use a form that specifies a POST action to reach this route.
post('/albums') do
  name = params[:album_name]
  year = params[:album_year]
  genre = params[:album_genre]
  artist = params[:album_artist]
  cost = params[:album_cost]
  album = Album.new({:name => name, :id => nil, :year => year, :genre => genre, :artist => artist, :status => true, :cost => cost})
  album.save()
  @albums = Album.all() # Adding this line will fix the error.
  erb(:albums)
end

# This route will show a specific album based on its ID. The value of ID here is #{params[:id]}.
get('/albums/:id') do
  @album = Album.find(params[:id].to_i())
  if @album == nil
    erb(:go_back)
  else
  erb(:album)
end
end

# his will take us to a page with a form for updating an album with an ID of #{params[:id]}.
get('/albums/:id/edit') do
  @album = Album.find(params[:id].to_i())
  erb(:edit_album)
end

# This route will update an album. We can't reach it with a URL. In a future lesson, we will use a form that specifies a PATCH action to reach this route.
patch('/albums/:id') do
  if params[:buy]
    @album = Album.find(params[:id].to_i())
    @album.sold
  else
    @album = Album.find(params[:id].to_i())
    @album.update(params[:name], params[:year], params[:genre], params[:artist], params[:cost])
  end
  @albums = Album.all
  erb(:albums)
end

# This route will delete an album. We can't reach it with a URL. In a future lesson, we will use a delete button that specifies a DELETE action to reach this route.
delete('/albums/:id') do
  @album = Album.find(params[:id].to_i())
  @album.delete()
  @albums = Album.all
  erb(:albums)
end

#This route will display a list of artists

get('/artists')do
  @artists = Artist.all()
  erb(:artists)
end

#This route will display an individual artists details
get('/artists/new') do
  erb(:new_artist)
end

get('/artists/:id')do
@artist = Artist.find(params[:id].to_i())
erb(:artist)
end


#This route will add a new artist to a list of artists

post('/artists')do
  name = params[:artist_name]
  artist = Artist.new({:name => name, :id => nil})
  artist.save()
  @artists = Artist.all()
  erb(:artists)
end

#This route will allow you to update an artist
patch('/artists/:id')do
  @artist = Artist.find(params[:id].to_i())
  @artist.update_name(params[:name])
  @artists = Artist.all
  erb(:artists)
end

#This route will allow you to delete an artist

delete('/artists/:id')do
  @artist = Artist.find(params[:id].to_i())
  @artist.delete()
  @artists = Artist.all
  erb(:artists)

end
