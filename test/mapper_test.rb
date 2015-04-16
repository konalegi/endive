require 'test_helper'

class MapperTest < Minitest::Test
  def test_match_methods
    example = {
      'get' => {
        '/photos' => 'photos#index',
        '/photos/:id' => 'photos#show',
      },
      'post' => { '/photos' => 'photos#create' },
      'put' => { '/photos/:id' => 'photos#update' },
      'delete' => { '/photos/:id' => 'photos#destroy' },
      'patch' => { '/photos/:id' => 'photos#update' },

      'get' => { '/photos/custom_action' => 'photos#custom_action' },
      'post' => { '/photos/custom_action' => 'photos#custom_action' }
    }

    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::TreeRouter) do
      post   'photos',      controller: 'photos', action: :create
      get    'photos',      controller: 'photos', action: :index
      get    'photos/:id',  controller: 'photos', action: :show
      put    'photos/:id',  controller: 'photos', action: :update
      patch  'photos/:id',  controller: 'photos', action: :update
      delete 'photos/:id',  controller: 'photos', action: :destroy
      match  'photos/custom_action', controller: 'photos', action: :custom_action, via: [:get, :post]
    end

    validate_router(example, Endive::Routing::Mapping::Mapper.instance.router)
  end

  def test_simple_resources_method
    example = {
      'get' => {
        '/photos' => 'photos#index',
        '/photos/:id' => 'photos#show',
      },
      'post' => { '/photos' => 'photos#create' },
      'put' => { '/photos/:id' => 'photos#update' },
      'delete' => { '/photos/:id' => 'photos#destroy' }
    }

    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::TreeRouter) do
      resources :photos
    end

    validate_router(example, Endive::Routing::Mapping::Mapper.instance.router)
  end

  def test_namespace_routes
    example = {
      'get' => {
        '/admin/photos' => 'admin/photos#index' ,
        '/v1/photos' => 'v1/photos#index'
        },
      'get' => {
        '/admin/photos/:id' => 'admin/photos#show',
        '/v1/photos/:id' => 'v1/photos#show'
      },
      'post' => {
        '/admin/photos' => 'admin/photos#create',
        '/v1/photos' => 'v1/photos#create'
      },
      'put' => {
        '/admin/photos/:id' => 'admin/photos#update',
        '/v1/photos/:id' => 'v1/photos#update'
      },
      'delete' => {
        '/admin/photos/:id' => 'admin/photos#destroy',
        '/v1/photos/:id' => 'v1/photos#destroy'
      }
    }

    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::TreeRouter) do
      namespace :admin do
        resources :photos
      end

      namespace :v1 do
        resources :photos
      end
    end

    validate_router(example, Endive::Routing::Mapping::Mapper.instance.router)
  end

  def test_member_and_collection
    example = {
      'get' => { '/admin/photos' => 'admin/photos#index' },
      'post' => { '/admin/photos/:id/publish' => 'admin/photos#publish' },
      'delete' => { '/admin/photos/delete_all' => 'admin/photos#delete_all' }
    }

    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::TreeRouter) do
      namespace :admin do
        resources :photos, only: [:index] do
          member do
            post :publish
          end

          collection do
            delete :delete_all
          end
        end
      end
    end

    validate_router(example, Endive::Routing::Mapping::Mapper.instance.router)
  end

  def test_concerns
    example = {
      'get' => {
        '/user/photos' => 'users/photos#index',
        '/user/photos/:id' => 'users/photos#show',
        '/posts/:post_id/photos' => 'posts/photos#index',
        '/posts/:post_id/photos/:id' => 'posts/photos#show',
        '/posts/:post_id/comments' => 'posts/comments#index'
      },

      'post' => {
        '/posts/:post_id/comments' => 'posts/comments#create'
      }
    }

    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::TreeRouter) do
      concern :photos do
        resources :photos, only: [:index, :show]
      end

      concern :comments do
        resources :comments, only: [:create, :index]
      end

      scope 'user', module: :users do
        concerns :photos
      end

      scope 'posts/:post_id', module: :posts do
        concerns :photos, :comments
      end
    end

    validate_router(example, Endive::Routing::Mapping::Mapper.instance.router)
  end

  def test_resources_nesting

    example = {
      'get' => {
        '/v1/users/:user_id/photos/:photo_id/likes/:id' => 'v1/likes#show',
        '/v1/users/:user_id/photos/:photo_id/comments/:id' => 'v1/comments#show',
        '/v2/persons/:person_id/photos/:photo_id/comments/:id' => 'v2/comments#show',
        '/v2/persons/:person_id/photos/:photo_id/likes/:id' => 'v2/likes#show',


        '/v2/persons/:person_id/photos/:photo_id/likes' => 'v2/likes#index',
        '/v2/persons/:person_id/photos/:photo_id/comments' => 'v2/comments#index',

        '/v2/persons/:person_id/photos' => 'v2/photos#index',
        '/v2/persons/:person_id/photos/:id' => 'v2/photos#show'

      }
    }

    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::TreeRouter) do
      concern :photos_concern do
        resources :photos do
          resources :likes
          resources :comments
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

      namespace :v2 do
        resources :persons do
          concerns :photos_concern
        end
      end
    end

    validate_router(example, Endive::Routing::Mapping::Mapper.instance.router)
  end

  def test_big_example
    example = {
        'get' => {
          '/organizations/:organization_id/photos' => 'organizations/photos#index',
          '/organizations/:organization_id/photos/:id' => 'organizations/photos#show',
          '/organizations/:organization_id/clients' => 'organizations/clients#index',
          '/organizations/:organization_id/friendship_offers' => 'organizations/friendship_offers#index',
          '/organizations/:organization_id/friends' => 'organizations/friends#index',
          '/organizations/:organization_id/movies' => 'organizations/movies#index',
          '/organizations/:organization_id/movies/:id' => 'organizations/movies#show',
          '/organizations/:organization_id/video_records' => 'organizations/video_records#index',
          '/organizations/:organization_id/video_records/:id' => 'organizations/video_records#show',
          '/organizations/:organization_id/music/albums' => 'organizations/music/albums#index',
          '/organizations/:organization_id/music/albums/:id' => 'organizations/music/albums#show',
        },

        'post' => {
          '/organizations/:organization_id/photos' => 'organizations/photos#create',
          '/organizations/:organization_id/photos/:id/publish' => 'organizations/photos#publish',
          '/organizations/:organization_id/friendship_offers' => 'organizations/friendship_offers#create',
          '/organizations/:organization_id/movies' => 'organizations/movies#create',
          '/organizations/:organization_id/video_records' => 'organizations/video_records#create',
          '/organizations/:organization_id/video_records/:id/publish' => 'organizations/video_records#publish',
          '/organizations/:organization_id/video_records/:id/add_to_profile' => 'organizations/video_records#add_to_profile',
          '/organizations/:organization_id/music/albums' => 'organizations/music/albums#create',
          '/organizations/:organization_id/music/albums/:id/change_state' => 'organizations/music/albums#change_state',
        },

        'put' => {
          '/organizations/:organization_id/photos/:id' => 'organizations/photos#update',
          '/organizations/:organization_id/friendship_offers/approve' => 'organizations/friendship_offers#approve',
          '/organizations/:organization_id/movies/:id' => 'organizations/movies#update',
          '/organizations/:organization_id/video_records/:id' => 'organizations/video_records#update',
          '/organizations/:organization_id/music/albums/:id' => 'organizations/music/albums#update',
        },

        'delete' => {
          '/organizations/:organization_id/photos/:id' => 'organizations/photos#destroy',
          '/organizations/:organization_id/friendship_offers/remove' => 'organizations/friendship_offers#remove',
          '/organizations/:organization_id/friends/:id' => 'organizations/friends#destroy',
          '/organizations/:organization_id/movies/:id' => 'organizations/movies#destroy',
          '/organizations/:organization_id/video_records/:id' => 'organizations/video_records#destroy',
          '/organizations/:organization_id/music/albums/:id' => 'organizations/music/albums#destroy',
        }
    }

    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::TreeRouter) do
      scope 'organizations/:organization_id', module: :organizations do
        resources :photos, only: [:show, :index, :update, :destroy, :create] do
          member do
            post :publish
          end
        end

        resources :clients, only: [:index]
        resources :friendship_offers, only: [:index, :create] do
          collection do
            put :approve
            delete :remove
          end
        end

        resources :friends, only: [:index, :destroy]
        resources :movies, only: [:show, :index, :update, :destroy, :create] do
          member do
            post :publish
          end
        end

        resources :video_records, only: [:show, :index, :update, :destroy, :create] do
          member do
            post :publish
            post :add_to_profile
          end
        end

        scope 'music', module: :music do
          resources :albums, only: [:index, :create, :update, :destroy, :show] do
            member do
              post :change_state
            end
          end
        end
      end
    end

    validate_router(example, Endive::Routing::Mapping::Mapper.instance.router)
  end

  def test_resources_param_option

    example = {
      'get' => {
        '/comments' => 'comments#index',
        '/comments/:gid' => 'comments#show'
      },

      'put' => { '/comments/:gid' => 'comments#update' }
    }

    Endive::Routing::Mapping::Mapper.build(Endive::Routing::Journey::TreeRouter) do
      resources :comments, only: [:show, :index, :update], param: :gid
    end

    validate_router(example, Endive::Routing::Mapping::Mapper.instance.router)
  end

  def validate_router(sample_routes, router)
    sample_routes.each do  |method, routes_hash|
      routes_hash.each do |route_path, controller|
        route_obj = router.find_route_template(method, route_path)
        route_and_action = "#{route_obj[:controller]}##{route_obj[:action]}" if route_obj
        assert_equal controller, route_and_action, "cant found route for method: #{method} and route: #{route_path}"
      end
    end
  end
end