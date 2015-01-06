class MoodCalculator
  def initialize user
    @grouping = {}
    @commit_index = 0
    @track_index = 0
  end

  def run track_list, commit_list
    while has_tracks track_list
      track = track_list[@track_index]
      process_track track, commit_list
    end
    @grouping.values.sort_by {|c| -c[:count]}
  end

  def has_tracks track_list
    @track_index < track_list.size
  end

  def process_track track, commit_list
    if has_commits commit_list and
        not handle_if_match commit_list[@commit_index], track
      @commit_index += 1
    else
      @track_index += 1
    end
  end

  def has_commits commit_list
    @commit_index < commit_list.size
  end

  def handle_if_match commit, track
    delta = diff_hours(commit[:timestamp], track[:timestamp])
    if delta >= 0 and delta < 2
      create_entry_if_needed track
      @grouping[track[:music_id]][:count] += 1
    else
      return false
    end
    return true
  end

  def create_entry_if_needed track
    if not @grouping.key? track[:music_id]
      @grouping[track[:music_id]] = {
        music_id: track[:music_id],
        name: track[:name], 
        artist: track[:artist],
        count: 0,
      }
    end
  end

  def diff_hours a, b
    ((a - b) / 1.hours)
  end

end

MoodUser = Struct.new(:github_token, :lastfm_user)

# class MoodUser
#   def initialize github_token, lastfm_user
#     @github_token = github_token
#     @lastfm_user = lastfm_user
#   end

#   def
# end