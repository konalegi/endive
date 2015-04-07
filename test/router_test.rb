require 'test_helper'

class RouterTest < Minitest::Test

  def test_resources_method

    example = {

      'get' => {
        '/photos' => 'photos#index',
        '/photos/:id' => 'photos#show',
      },

      'post' => {
        '/photos' => 'photos#create',
      },

      'put' => {
        '/photos/:id' => 'photos#update',
      },

      'delete' => {
        '/photos/:id' => 'photos#destroy'
      }

    }


    Endive::Router.build do

      resources :photos

    end

    result =  Endive::Router.routes


    assert_equal true, compare(example, result)

  end




  def test_resource_method
    example = {

      'get' => {
        '/photo' => 'photos#show',
      },

      'post' => {
        '/photo' => 'photos#create',
      },

      'put' => {
        '/photo' => 'photos#update',
      },

      'delete' => {
        '/photo' => 'photos#destroy'
      }

    }


    Endive::Router.build do

      resource :photo

    end

    result = Endive::Router.routes


    assert_equal true, compare(example, result)

  end


  def test_namespace_method

    example = {

        'get' => {
            '/admin/photo' => 'admin/photos#show',
        },

        'post' => {
            '/admin/photo' => 'admin/photos#create',
        },

        'put' => {
            '/admin/photo' => 'admin/photos#update',
        },

        'delete' => {
            '/admin/photo' => 'admin/photos#destroy'
        }

    }


    Endive::Router.build do
      namespace :admin do
        resource :photo
      end
    end

    result =  Endive::Router.routes
    assert_equal true, compare(example, result)

  end


  def test_member_and_collection


    example = {

        'get' => {
          '/admin/photos' => 'admin/photos#index',
        },


        'post' => {
          '/admin/photos/:id/publish' => 'admin/photos#publish'
        },

        'delete' => {
          '/admin/photos/delete_all' => 'admin/photos#delete_all'
        }


    }


    Endive::Router.build do
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

    result = Endive::Router.routes
    assert_equal true, compare(example, result)


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



    Endive::Router.build do

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

    result = Endive::Router.routes
    assert_equal true, compare(example, result)

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


    Endive::Router.build do


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


    result = Endive::Router.routes

    assert_equal true, compare(example, result)

  end



  def test_resources_param_option

    example = {

        'get' => {
          '/comments' => 'comments#index',
          '/comments/:gid' => 'comments#show'
        },

        'put' => {
          '/comments/:gid' => 'comments#update'
        }

    }

    Endive::Router.build do

      resources :comments, only: [:show, :index, :update], param: :gid

    end

    result = Endive::Router.routes

    assert_equal true, compare(example, result)

  end




  def test_find_route

    Endive::Router.build do

      resources :comments, only: [:show, :index]

    end


    route = Endive::Router.find_route('get', '/comments/1').to_s

    assert_equal route, '/comments/:id'
  end



  def show(routes)
    count = 0

    routes.each do |meth, value|

      value.each do |path , action|
        count += 1
        p "#{meth.to_s.upcase}  #{path.to_s}  CONTROLLER : #{action}"
      end

    end

    p "count = #{count}"
  end

  def compare(expected, actual, options = {})

    expected.each do |meth, value|

      value.each do |path, action|
        if options[:debug].present?
          p path
          p action
          p actual[meth][Mustermann.new path]
        end

        return false if action != actual[meth][Mustermann.new path]
      end

    end

    true
  end


end