class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.find_in_tmdb(terms, api_key = ENV.fetch('TMDB_API_KEY'))
    query = { api_key: api_key, query: terms[:title] }
    query[:year] = terms[:release_year] if terms[:release_year].present?
    query[:language] = 'en' if terms[:language] == 'en'

    response = Faraday.get('https://api.themoviedb.org/3/search/movie', query)
    raise Faraday::Error, "TMDb returned HTTP #{response.status}" unless response.success?

    results = JSON.parse(response.body).fetch('results')
    if terms[:language] == 'en'
      results = results.select { |result| result['original_language'] == 'en' }
    end

    movies = results.map do |result|
      Movie.new(
        title: result['title'],
        description: result['overview'],
        release_date: result['release_date'].presence,
        rating: 'R'
      )
    end
    saved_movies = Movie.where(title: movies.map(&:title)).pluck(:title, :release_date).to_set
    movies.reject { |movie| saved_movies.include?([movie.title, movie.release_date]) }
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end
end


