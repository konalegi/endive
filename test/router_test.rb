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
          '/admin/photos/:photo_id/publish' => 'admin/photos#publish'
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


  def test_find_route

    Endive::Router.build do

      resources :comments, only: [:show, :index]

    end


    route = Endive::Router.find_route('get', '/comments/1').to_s

    assert_equal route, '/comments/:id'
  end



  def show(routes)
    routes.each do |meth, value|

      value.each do |path , action|
        p "#{meth.to_s.upcase}  #{path.to_s}  CONTROLLER : #{action}"
      end

    end
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