require 'spec_helper'

describe JsonDiff do
  # Arrays

  it "should be able to diff two empty arrays" do
    diff = JsonDiff.diff([], [])
    expect(diff).to eql([])
  end

  it "should be able to diff an empty array with a filled one" do
    diff = JsonDiff.diff([], [1, 2, 3], include_was: true)
    expect(diff).to eql([
      {'op' => 'add', 'path' => "/0", 'value' => 1},
      {'op' => 'add', 'path' => "/1", 'value' => 2},
      {'op' => 'add', 'path' => "/2", 'value' => 3},
    ])
  end

  it "should be able to diff a filled array with an empty one" do
    diff = JsonDiff.diff([1, 2, 3], [], include_was: true)
    expect(diff).to eql([
      {'op' => 'remove', 'path' => "/0", 'was' => 1},
      {'op' => 'remove', 'path' => "/0", 'was' => 2},
      {'op' => 'remove', 'path' => "/0", 'was' => 3},
    ])
  end

  it "should be able to diff a 1-array with a filled one" do
    diff = JsonDiff.diff([0], [1, 2, 3], include_was: true)
    expect(diff).to eql([
      {'op' => 'remove', 'path' => "/0", 'was' => 0},
      {'op' => 'add', 'path' => "/0", 'value' => 1},
      {'op' => 'add', 'path' => "/1", 'value' => 2},
      {'op' => 'add', 'path' => "/2", 'value' => 3},
    ])
  end

  it "should be able to diff a filled array with a 1-array" do
    diff = JsonDiff.diff([1, 2, 3], [0], include_was: true)
    expect(diff).to eql([
      {'op' => 'remove', 'path' => "/2", 'was' => 3},
      {'op' => 'remove', 'path' => "/1", 'was' => 2},
      {'op' => 'remove', 'path' => "/0", 'was' => 1},
      {'op' => 'add', 'path' => "/0", 'value' => 0},
    ])
  end

  it "should be able to diff two integer arrays" do
    diff = JsonDiff.diff([1, 2, 3, 4, 5], [6, 4, 3, 2], include_was: true)
    expect(diff).to eql([
      {'op' => 'remove', 'path' => "/4", 'was' => 5},
      {'op' => 'remove', 'path' => "/0", 'was' => 1},
      {'op' => 'move', 'from' => "/0", 'path' => "/2"},
      {'op' => 'move', 'from' => "/1", 'path' => "/0"},
      {'op' => 'add', 'path' => "/0", 'value' => 6},
    ])
  end

  it "should be able to diff two arrays with mixed content" do
    diff = JsonDiff.diff(["laundry", 12, {'pillar' => 0}, true], [true, {'pillar' => 1}, 3, 12], include_was: true)
    expect(diff).to eql([
      {'op' => 'replace', 'path' => "/2/pillar", 'was' => 0, 'value' => 1},
      {'op' => 'remove', 'path' => "/0", 'was' => "laundry"},
      {'op' => 'move', 'from' => "/0", 'path' => "/2"},
      {'op' => 'move', 'from' => "/1", 'path' => "/0"},
      {'op' => 'add', 'path' => "/2", 'value' => 3},
    ])
  end

  # Objects

  it "should be able to diff two objects with mixed content" do
    diff = JsonDiff.diff(
      {'string' => "laundry", 'number' => 12, 'object' => {'pillar' => 0}, 'list' => [2, 4, 1], 'bool' => false, 'null' => nil},
      {'string' => "laundry", 'number' => 12, 'object' => {'pillar' => 1}, 'list' => [1, 2, 3], 'bool' => true, 'null' => nil},
      include_was: true)
    expect(diff).to eql([
      {'op' => 'replace', 'path' => "/object/pillar", 'was' => 0, 'value' => 1},
      {'op' => 'remove', 'path' => "/list/1", 'was' => 4},
      {'op' => 'move', 'from' => "/list/0", 'path' => "/list/1"},
      {'op' => 'add', 'path' => "/list/2", 'value' => 3},
      {'op' => 'replace', 'path' => "/bool", 'was' => false, 'value' => true},
    ])
  end

  # Options

  it "should be able to diff two integer arrays with original indices" do
    diff = JsonDiff.diff([1, 2, 3, 4, 5], [6, 4, 3, 2], original_indices: true)
    expect(diff).to eql([
      {'op' => 'remove', 'path' => "/4"},
      {'op' => 'remove', 'path' => "/0"},
      {'op' => 'move', 'from' => "/1", 'path' => "/3"},
      {'op' => 'move', 'from' => "/3", 'path' => "/1"},
      {'op' => 'add', 'path' => "/0", 'value' => 6},
    ])
  end

  it "should be able to diff two integer arrays without move operations" do
    diff = JsonDiff.diff([1, 2, 3, 4, 5], [6, 4, 3, 2], moves: false)
    expect(diff).to eql([
      {'op' => 'remove', 'path' => "/4"},
      {'op' => 'remove', 'path' => "/0"},
      {'op' => 'add', 'path' => "/0", 'value' => 6},
    ])
  end

  it "should be able to diff two integer arrays without add operations" do
    diff = JsonDiff.diff([1, 2, 3, 4, 5], [6, 4, 3, 2], additions: false)
    expect(diff).to eql([
      {'op' => 'remove', 'path' => "/4"},
      {'op' => 'remove', 'path' => "/0"},
      {'op' => 'move', 'from' => "/0", 'path' => "/2"},
      {'op' => 'move', 'from' => "/1", 'path' => "/0"},
    ])
  end

end
