class LastfmCollector
  def initialize user
    @user = user
    @tracks = Set.new
  end

  def get_tracks
    api_key = "139aaea3d50f2084c2a71252d85e716e"
    api_secret = "b5f4e4d2249c7aa53bdcd4b1589a8910"
    @client = Lastfm.new(api_key, api_secret)
    
    get_all_tracks 'nukdf'
    @tracks
  end

  def get_all_tracks username
    page = 1
    tracks = fetch_track_page username, page
    while not tracks.empty?
      tracks.each do |track|
        @tracks << translate_track_info(track) if not track["nowplaying"]
      end
      p @tracks.size
      page += 1
      tracks = fetch_track_page username, page
    end
  end

  def fetch_track_page user, page
    @client.user.get_recent_tracks :user =>user, :extended => 1,
                                  :limit => 200, :page => page
  end

  def translate_track_info track
    {
      name: track["name"],
      artist: track["artist"]["content"],
      music_id: track["url"],
      timestamp: Time.parse(track["date"]["content"]),
    }
  end
end