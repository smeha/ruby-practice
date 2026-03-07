RSpec.describe "#is_prime?" do
  context "when given a prime number" do
    it "returns true for 2 (smallest prime)" do
      expect(is_prime?(2)).to be true
    end

    it "returns true for 3" do
      expect(is_prime?(3)).to be true
    end

    it "returns true for 7" do
      expect(is_prime?(7)).to be true
    end

    it "returns true for a large prime" do
      expect(is_prime?(97)).to be true
    end
  end

  context "when given a non-prime" do
    it "returns false for 1" do
      expect(is_prime?(1)).to be false
    end

    it "returns false for 0" do
      expect(is_prime?(0)).to be false
    end

    it "returns false for a negative number" do
      expect(is_prime?(-5)).to be false
    end

    it "returns false for 4" do
      expect(is_prime?(4)).to be false
    end

    it "returns false for 9" do
      expect(is_prime?(9)).to be false
    end
  end

  context "when given a non-integer" do
    it "returns false for a float" do
      expect(is_prime?(7.0)).to be false
    end

    it "returns false for a string" do
      expect(is_prime?("7")).to be false
    end
  end
end

RSpec.describe "#eval_poly" do
  it "evaluates 2x² + 3x + 1 at x=5 to 66" do
    expect(eval_poly([2, 3, 1], 5)).to eq(66)
  end

  it "evaluates a constant polynomial" do
    expect(eval_poly([42], 99)).to eq(42)
  end

  it "evaluates an empty coefficients array to 0" do
    expect(eval_poly([], 5)).to eq(0)
  end

  it "raises ArgumentError when coefficients is not an Array" do
    expect { eval_poly("bad", 5) }.to raise_error(ArgumentError)
  end
end
