require_relative '../../lib/viewr/dependency_resolver'

describe Viewr::DependencyResolver do

  # test dependencies
  #
  #     A    B
  #   / | \ /
  #  C  |  D
  #  |  \ /|
  #  |   E |
  #   \ / \|
  #    F   G

  Item = Struct.new(:name, :dependencies)

  let(:a) { Item.new(:a, []) }
  let(:b) { Item.new(:b, []) }
  let(:c) { Item.new(:c, [:a]) }
  let(:d) { Item.new(:d, [:a, :b]) }
  let(:e) { Item.new(:e, [:a, :d]) }
  let(:f) { Item.new(:f, [:c, :e]) }
  let(:g) { Item.new(:g, [:e, :d]) }

  def items
    [a, b, c, d, e, f, g].shuffle
  end

  it "resolves a list of dependencies into a runnable sequence" do
    sequence = Viewr::DependencyResolver.resolve_to_sequence(items)

    expect(sequence[0, 2]).to match_array([a, b])
    expect(sequence[2, 2]).to match_array([c, d])
    expect(sequence[4]).to eql(e)
    expect(sequence[-2, 2]).to match_array([f, g])
  end

  it "resolves an empty list to an empty array" do
    expect(Viewr::DependencyResolver.resolve_to_sequence([])).to be_empty
  end

  context 'unsatisfiable dependencies' do
    let(:cyclic) { Item.new(:a, Set.new([:c])) }

    it 'raises on cyclic dependencies' do
      expect { Viewr::DependencyResolver.resolve_to_sequence([cyclic, c]) }.to \
        raise_error(Viewr::UnsatisfiableDependenciesError)
    end

    it 'raises on missing dependencies' do
      expect { Viewr::DependencyResolver.resolve_to_sequence([c]) }.to \
        raise_error(Viewr::UnsatisfiableDependenciesError)
    end
  end

end
