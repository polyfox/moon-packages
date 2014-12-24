module DeckHelper
  def self.generate_tier(tier, num = 80)
    cards = DataCache.cards

    deck = []

    # card ratios
    sup = 0.10
    off = 0.50
    dff = 0.20
    oth = 1.0 - sup - off - dff

    tier_cards = cards.select do |card|
      card.tier == tier
    end

    sup_cards = tier_cards.select do |card|
      card.type == 'support'
    end

    off_cards = tier_cards.select do |card|
      card.type == 'offense'
    end

    dff_cards = tier_cards.select do |card|
      card.type == 'chain'
    end

    oth_cards = tier_cards

    (sup * num).to_i.times do
      deck << sup_cards.sample
    end

    (off * num).to_i.times do
      deck << off_cards.sample
    end

    (dff * num).to_i.times do
      deck << dff_cards.sample
    end

    (oth * num).to_i.times do
      deck << oth_cards.sample
    end

    deck.map(&:copy)[0, num]
  end

  # Generates a simple Tier 1 deck, the default number of cards in the deck is
  # 40
  def self.generate_tier1(num = 80)
    generate_tier(1, num)
  end

  def self.generate_tier2(num = 80)
    t1 = 0.60
    cards = generate_tier(1, (num * t1).to_i)
    cards.concat(generate_tier(2, num - cards.size))
  end

  def self.generate_tier3(num = 80)
    t1 = 0.45
    t2 = 0.35
    cards = generate_tier(1, (num * t1).to_i)
    cards.concat(generate_tier(2, (num * t2).to_i))
    cards.concat(generate_tier(3, (num - cards.size)))
  end
end
