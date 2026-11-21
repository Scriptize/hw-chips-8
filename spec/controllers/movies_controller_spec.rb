require 'rails_helper'

RSpec.describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    let(:terms) { { title: 'hardware', language: 'en' } }

    before(:each) do
      @fake_results = [double('movie1'), double('movie2')]
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with(terms).and_return(@fake_results)

      get :search_tmdb, params: terms
    end

    describe 'after valid search' do
      before(:each) do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: terms
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end
  end

  describe 'adding a movie' do
    it 'saves the selected movie and redirects to search' do
      attributes = { title: 'Manhunter', rating: 'R', release_date: '1986-08-15' }

      expect {
        post :add_movie, params: { movie: attributes }
      }.to change(Movie, :count).by(1)

      expect(Movie.last.title).to eq('Manhunter')
      expect(response).to redirect_to(search_path)
      expect(flash[:success]).to eq('Manhunter was successfully added to RottenPotatoes.')
    end
  end
end