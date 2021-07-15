require 'spec_helper'
require 'mood_calculator'
require 'active_support/time'

describe MoodCalculator do 
  before do
    @mood_calculator = MoodCalculator.new()
    @timestamp = Time.new 2012,10,06, 13,33,45
    @timestamp_less_one_hour = @timestamp - 1.hours
    @timestamp_less_two_hours = @timestamp - 2.hours
  end

  def track(id, stamp, name = "Dummy Song / Dummy")
    {
      music_id:id,
      timestamp:stamp,
      name: "m#{id}",
      artist:"a#{id}"
    }
  end

  def commit(id, stamp)
    {
      commit_id:id,
      timestamp:stamp
    }
  end

  def count(music_id, count)
    {
      music_id:music_id,
      count:count,
      name: "m#{music_id}",
      artist:"a#{music_id}"
    }
  end

  it "empty data results in nothing" do
    expect(
      @mood_calculator.run([],[])
    ).to eq []

    expect(
      @mood_calculator.run([],[commit(1, @timestamp)])
    ).to eq []

    expect(
      @mood_calculator.run([track(1, @timestamp)], [])
    ).to eq []
  end

  it "returns all music count near 2 hours before a single commit" do
    expect(
      @mood_calculator.run(
        [
          track(1, @timestamp),
          track(2, @timestamp_less_two_hours + 1.minutes),
          track(3, @timestamp_less_two_hours - 1.minutes),
        ],
        [
          commit(1, @timestamp)
        ]
      )
    ).to eq [
      count(1, 1),
      count(2, 1)
    ]
  end

  it "returns all music count near 2 hours before all commits" do
    expect(
      @mood_calculator.run(
        [
          track(1, @timestamp),
          track(2, @timestamp_less_two_hours + 1.minutes),
          track(3, @timestamp_less_two_hours - 1.minutes),
        ],
         [
          commit(1, @timestamp),
          commit(2, @timestamp_less_two_hours)
        ]
      )
    ).to eq [
      count(1,1),
      count(2,1),
      count(3,1)
    ]
  end

  it "does not count the same track twice" do
    expect(
      @mood_calculator.run(
        [
          track(1, @timestamp),
          track(2, @timestamp_less_two_hours + 1.minutes),
          track(3, @timestamp_less_two_hours - 1.minutes),
        ],
        [
          commit(1, @timestamp),
          commit(2, @timestamp_less_one_hour)
        ]
      )
    ).to eq [
      count(1, 1),
      count(2, 1),
      count(3, 1)
    ]
  end

  it "actually counts the music" do
    expect(
      @mood_calculator.run(
        [
          track(1, @timestamp),
          track(1, @timestamp),
          track(1, @timestamp)
        ],
        [
          commit(1, @timestamp)
        ]
      )
    ).to eq [
      count(1, 3)
    ]
  end

  it "order result by counting" do
    expect(
      @mood_calculator.run(
        [
          track(2,@timestamp),
          track(1,@timestamp),
          track(3,@timestamp),
          track(1,@timestamp),
          track(2,@timestamp),
          track(1,@timestamp),
        ],
        [
          commit(1, @timestamp)
        ]
      )
    ).to eq [
      count(1, 3),
      count(2, 2),
      count(3, 1)
    ]
  end
end