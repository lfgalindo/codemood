class LastfmCollector
  def initialize user
    @user = user
    @tracks = Set.new
  end

  def get_tracks
    @client = Lastfm.new(Settings.lastfm.key, Settings.lastfm.secret)
    get_all_tracks @user.lastfm_user
    @tracks
  end

  def get_all_tracks username
    (TrackFetcher.new @client, @user, @tracks).fetch
  end

end

class TrackFetcher
  def initialize client, user, tracks_collection
    @client = client
    @user = user
    @tracks_collection = tracks_collection
    @tracks = []
  end

  def fetch
    @page = 1
    fetch_next_track_page 
    while has_tracks
      process_tracks
      fetch_next_track_page
      puts @tracks_collection.size
      puts @tracks_collection.to_a.last
    end
  end

  def has_tracks
    not @tracks.empty?
  end

  def process_tracks
    @tracks.each do |track|
      @tracks_collection << translate_track_info(track) if not track["nowplaying"]
    end
  end

  def translate_track_info track
    {
      name: track["name"],
      artist: track["artist"]["name"],
      music_id: track["url"],
      timestamp: Time.parse(track["date"]["content"]),
    }
  end

  def fetch_next_track_page 
    retries = 0
    error = nil
    while retries < 3
      begin
        @tracks = @client.user.get_recent_tracks :user =>@user.lastfm_user, 
                                  :extended => 1,
                                  :limit => 200, :page => @page
        @page += 1
        return
      rescue Exception => e
        retries += 1
        error = e
      end
    end
    raise error
  end
end