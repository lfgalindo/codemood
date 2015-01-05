class MoodCalculator
  def initialize user
    @grouping = []
  end

  def run track_list, commit_list
    track_list.each do |track|
      commit_list.each do |commit|
        handle_if_match commit, track
      end
    end
    @grouping
  end

  def handle_if_match commit, track
    delta = diff_hours(commit[:timestamp], track[:timestamp])
    if delta >= 0 and delta < 2
      @grouping << {
        music_id: track[:music_id],
        count:1
      }
    end
  end

  def diff_hours a, b
    ((a - b) / 1.hours)
  end

end

class MoodUser
end