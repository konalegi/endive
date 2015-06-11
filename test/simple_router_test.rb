require 'test_helper'

class SimpleRouterTest < Minitest::Test
  def test_match_methods
    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::SimpleRouter) do
      concern :photos_concern do
        resources :photos do
          resources :comments
          resources :likes
        end
      end

      namespace :v1 do
        resources :users do
          concerns :photos_concern
        end

        resources :products do
          concerns :photos_concern
        end
      end

    end
    router = Endive::Routing::Mapping::Mapper.instance.router

    refute_nil router.find_route('get', '/v1/users/1/photos/3/comments/45')
    refute_nil router.find_route('get', '/v1/users/1/photos/3/likes/23')
    refute_nil router.find_route('get', '/v1/products/1/photos/3/comments/45')
    refute_nil router.find_route('get', '/v1/products/1/photos/3/likes/23')
    refute_nil router.find_route('get', '/v1/products/1/photos/3/likes')
  end

  def test_options_method
    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::SimpleRouter) do
      match '*path', controller: 'application', action: 'allow_cors', via: :options
    end

    router = Endive::Routing::Mapping::Mapper.instance.router
    refute_nil router.find_route('options', '/v1/users/1/photos/3/comments/45')
  end

end