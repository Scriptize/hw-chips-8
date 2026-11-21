
require 'rails_helper'

RSpec.describe Movie, type: :model do
  describe '.find_in_tmdb' do
    let(:terms) { { title: 'Olympics', release_year: '2000', language: 'en' } }

    it 'excludes a saved movie while keeping the other search results' do
        Movie.create!(
            title: 'Sydney 2000 Olympics Opening Ceremony',
            release_date: '2000-09-15',
            rating: 'R'
        )

        movies = Movie.find_in_tmdb(terms, 'test-key')

        expect(movies.map(&:title)).to eq(['Sydney 2000 Olympics Closing Ceremony'])
    end
    it 'calls Faraday with the movie search' do
      expect(Faraday).to receive(:get).and_call_original

      Movie.find_in_tmdb(terms, 'test-key')
    end

    it 'returns the matching movies without saving them' do
      movies = Movie.find_in_tmdb(terms, 'test-key')

      expect(WebMock).to have_requested(:get, 'https://api.themoviedb.org/3/search/movie')
        .with(query: {
          'api_key' => 'test-key',
          'query' => 'Olympics',
          'year' => '2000',
          'language' => 'en'
        })

      expect(movies.map(&:title)).to eq([
        'Sydney 2000 Olympics Opening Ceremony',
        'Sydney 2000 Olympics Closing Ceremony'
      ])
      expect(movies).to all(be_new_record)
    end
  end
end