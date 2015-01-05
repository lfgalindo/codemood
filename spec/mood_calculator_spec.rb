require 'spec_helper'
require 'mood_calculator'
require 'active_support/time'

describe MoodCalculator do 

  before do
    @calc = MoodCalculator.new MoodUser.new
  end

  def track id, stamp, name = "Dummy Song / Dummy"
    {music_id:id, timestamp:stamp}
  end

  def commit id, stamp
    {commit_id:id, timestamp:stamp}
  end

  def count music_id, count
    {music_id:music_id, count:count}
  end

  it "empty data results in nothing" do
    expect(@calc.run [],[]).to eq []
    expect(@calc.run [],[commit(1,Time.now)]).to eq []
    # expect(@calc.run [{music_id:1, timestamp:Time.now}],[]).to eq []
  end

  it "returns all music count near 2 hours before a single commit" do
    stamp = Time.new 2012,10,06, 13,33,45
    limit = stamp - 2.hours
    expect(
      @calc.run [ 
                  track(1,stamp),
                  track(2,limit+1.minutes),
                  track(3,limit-1.minutes),
                ],
                [commit(1,stamp)]
    ).to eq [count(1,1), count(2,1)]
  end

  it "returns all music count near 2 hours before all commits" do
    stamp = Time.new 2012,10,06, 13,33,45
    limit = stamp - 2.hours
    expect(
      @calc.run [ track(1,stamp),
                  track(2,limit+1.minutes),
                  track(3,limit-1.minutes),
                ],
                [ commit(1,stamp),commit(2,limit)]
    ).to eq [ count(1,1), count(2,1), count(3,1)]
  end
end