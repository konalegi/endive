$:.unshift(File.expand_path("..", File.dirname(__FILE__)) + '/lib')
require 'endive'
require 'benchmark'


def test_router(router_class, msg = nil)
  Endive::Routing::Mapping::Mapper.build(router_class) do
    namespace :v1 do
      resources :participants, only: [:index], defaults: { format: :json }
      namespace :app_store do
        resources :applications, only: [:index, :install, :uninstall, :hide, :show, :move] do
          member do
            post :install
            put :hide
            put :reveal
            delete :uninstall
            put :move
          end
        end
      end

      get 'auth/:provider/callback', to: 'users/social_infos#auth'
      get 'auth/failure', to: 'users/social_infos#failure'
      get 'auth/:provider/signout', to: 'users/social_infos#destroy'

      resource :remote_notification, only: [:create], defaults: {format: :json}
      resource :vote,  only: [:create, :destroy], defaults: {format: :json}

      namespace :common do
        scope ':gid' do
          resources :images, only: [:index, :create, :destroy, :show], defaults: { format: :json }

          resources :tags, only: [:index, :create, :destroy, :show], defaults: { format: :json }

          resources :videos, only: [:index, :create, :destroy, :show], defaults: { format: :json } do
            member do
              post :take_screenshots
            end
          end
        end
      end

      namespace :media do
        resources :movies, only: [:show, :index], defaults: { format: :json }
        resources :video_records, only: [:show, :index], defaults: { format: :json }
        resources :photos, only: [:show, :index], defaults: { format: :json }
        resources :movie_categories, only: [:index], defaults: {format: :json}

        scope 'music', module: :music do
          resources :albums, only: [:index, :show], defaults: { format: :json }
          resources :audios, only: [:index, :show], defaults: { format: :json }
          resources :genres, only: [:index], defaults: { format: :json }
        end

      end

      resource :session, only: [:create, :show], defaults: { format: :json }

      scope 'session', module: :sessions do
        resources :profiles, only: [:index, :change] , defaults: {format: :json} do
          collection do
            put :change
            get :current
          end
        end
      end

      resource :user, only: [:create, :show, :update], defaults: { format: :json } do
        put :password, to: :update_password
      end

      resources :notifications, only: [:index], defaults: { format: :json } do
        collection do
          put :mark_all_read
        end
        member do
          put :mark_read
        end
      end

      resources :chats, only: [:index, :create, :show ], defaults: {format: :json} do
        member do
          put :make_all_read
        end
      end

      scope 'chats/:chat_id', module: :chats do
        resources :messages, only: [:index, :create, :update_read_status] do
          collection do
            put :update_read_status
          end
        end
      end

      resource :gm_card, only: [:create, :show, :destroy], defaults: { format: :json } do
        member do
          post :init_ds
          post :init_checkout
        end
      end

      scope 'user', module: :users do
        get :exists, defaults: { format: :json }
        resource :verify, only: [:create, :show], defaults: { format: :json }
        resources :organizations, only: [], defaults: { format: :json } do
          get :root, on: :collection
        end
        resources :social_infos, only: [:index, :show, :create, :destroy], defaults: {format: :json}
      end

      scope 'persons/:person_id', module: :persons do
        resources :video_records, only: [:show, :index, :update, :destroy, :create, :publish], defaults: {format: :json} do
          member do
            post :publish
            post :add_to_profile
          end
        end

        resources :photos, only: [:show, :index, :update, :destroy, :create, :publish], defaults: {format: :json} do
          member do
            post :publish
          end
        end

        resources :movies, only: [:index, :show], defaults: { format: :json }
        resources :employees, only: [:index], defaults: { format: :json }

        resources :friends, only: [:index, :destroy], defaults: { format: :json } do
          collection do
            get :found_friends
          end
        end
        resources :colleagues, only: [:index], defaults: { format: :json }

        scope 'music', module: :music do
          resources :albums, only: [:index, :show], defaults: { format: :json }
        end
      end

      resources :organizations, only: [:show, :create, :update, :index], defaults: { format: :json } do
        member do
          post :hide
          post :reveal
          get :structure
          delete :remove_logo
        end
      end

      scope 'organizations/:organization_id', module: :organizations do
        resources :photos, only: [:show, :index, :update, :destroy, :create, :publish], defaults: {format: :json} do
          member do
            post :publish
          end
        end

        resources :clients, only: [:index], defaults: { format: :json }
        resources :friendship_offers, only: [:index, :create, :approve, :remove], defaults: { format: :json } do
          collection do
            put :approve
            delete :remove
          end
        end

        resources :friends, only: [:index, :destroy], defaults: { format: :json }

        resources :movies, only: [:show, :index, :update, :destroy, :create, :publish], defaults: {format: :json} do
          member do
            post :publish
          end
        end

        resources :video_records, only: [:show, :index, :update, :destroy, :create, :publish], defaults: {format: :json} do
          member do
            post :publish
            post :add_to_profile
          end
        end

        scope 'music', module: :music do
          resources :albums, only: [:index, :create, :update, :destroy, :show, :change_state], defaults: { format: :json } do
            member do
              post :change_state
            end
          end
          scope 'albums/:album_id', module: :albums do

            resources :audios, only: [:index, :create, :update, :destroy, :show]
          end
        end

        resources :photos, only: [:index, :create, :destroy], defaults: { format: :json }
        resources :departments, only: [:index, :create, :update, :destroy], defaults: { format: :json }
        resources :subsidiary_categories, only: [:index, :create, :update, :destroy], defaults: { format: :json }
        resource :extended_info, defaults: { format: :json }
        resource :market, only: [ :show ], defaults: { format: :json }

        resources :employees, only: [:index, :show, :destroy, :update], defaults: { format: :json } do
          put :dismiss, on: :member
          put :change_owner, on: :collection
        end

        resources :subsidiaries, only: [:index, :destroy], defaults: { format: :json }

        resources :subsidiary_offers, only: [:index, :create, :show, :destroy] do
          put :confirm, on: :member
        end

        resources :employee_offers, only: [:create, :destroy] do
          put :confirm, on: :member
        end

        resources :vacancies, only: [:index, :create, :update, :destroy]

        scope 'vacancies/:vacancy_id', module: :vacancies do
          resources :replies, only: [:index, :create, :show] do
            delete :my_reply, to: :destroy, on: :collection
          end
        end

        scope 'market', module: :markets do

          scope 'warehouse', module: :warehouses do
            resources :variants, only: [:index, :update, :destroy]
          end

          resources :orders, only: [:index, :show], param: :token, defaults: { format: :json }

          scope 'orders/:token', module: :orders do

            resource :contract, only: [:show] do
              member do
                post :notify_seller
                put :confirm_by_seller
              end
            end

            resource :shipping, only: [:change_state, :show], defaults: { format: :json } do
              member do
                post :change_state
              end
            end

            resource :service_status, only: [:show], defaults: { format: :json } do
              member do
                post :change_state
              end
            end
          end



          resources :auctions, only: [:create, :update, :show, :index, :destroy], defaults: { format: :json } do
            member do
              post :duplicate
              post :change_state
            end
          end

          scope 'auctions/:auction_id', module: :auctions do
            resources :bids, only: [:index, :create], defaults: { format: :json }
          end

          resources :categories, only: [:index, :create, :update, :destroy], defaults: { format: :json }
          resources :products, only: [:index, :create, :update, :show, :destroy], defaults: { format: :json } do
            member do
              post :duplicate
              post :publish
            end
          end

          scope 'products/:product_id', module: :products do
            resources :variants, only: [:create, :update, :index, :destroy, :show], defaults: { format: :json }
            resources :properties, only: [:index, :create, :update, :destroy], defaults: { format: :json }
            resources :shippings, only: [:index, :create, :update, :destroy], defaults: { format: :json }
          end
        end
      end

      scope 'market', module: :markets do
        resources :orders, only: [:create, :index, :show], param: :token, defaults: { format: :json } do
          member do
            post :purchase
            put  :update_goods
            delete :delete_goods

            post :init_ds
            post :init_checkout
          end
        end
        resources :auctions, only: [:index, :show], defaults: { format: :json }
        scope 'auctions/:auction_id', module: :auctions do
          resources :bids, only: [:index, :create], defaults: { format: :json }
        end

        resources :products, only: [:index, :show], defaults: { format: :json }
        resources :categories, only: [:index], defaults: { format: :json }

        scope 'orders/:token', module: :orders do
          resource :shipping, only: [:create], defaults: { format: :json }
          resource :service_status, only: [:create, :show], defaults: { format: :json }

          resource :contract, only: [:create, :show, :destroy], defaults: { format: :json } do
            member do
              put :confirm_by_buyer
              post :notify_buyer
            end
          end

          scope 'contract', module: :contracts do
            resources :documents, only: [:create, :show, :index, :destroy]
          end
        end
      end

      namespace :catalog do
        resources :classifiers, only: [:index], defaults: { format: :json }
        namespace :fias do
          resources :streets, only: [:index], defaults: { format: :json }
          resources :regions, only: [:index], defaults: { format: :json }
          resources :cities, only: [:index], defaults: { format: :json }
        end

        resources :sections, only: [:index], defaults: {format: :json}
        resources :sub_sections, only: [:index], defaults: {format: :json}
        scope 'sub_sections/:sub_section_id', module: :sub_sections do
          resources :positions, only: [:index]
        end
      end

      resources :employees, only: [:index, :show], defaults: { format: :json }
      resources :persons, only: [:index, :show, :update], defaults: { format: :json } do
        delete :remove_avatar, on: :member
      end
      resources :vacancies, only: [:index, :show], defaults: { format: :json }

      scope 'vacancies/:vacancy_id', module: :vacancies do
        resources :replies, only: [:index, :create, :show] do
          delete :my_reply, to: :destroy, on: :collection
        end
      end

      resources :posts, only: [:index, :show], defaults: { format: :json }
    end
  end

  get = [

      '/v1/organizations/33/market/products/34/variants',
      '/v1/organizations/65/market/products/300',
      '/v1/persons/35',
      '/v1/organizations'
  ]

  post = [
      '/v1/organizations/45/vacancies/323/replies',
      '/v1/organizations/46/subsidiary_offers',
      '/v1/organizations/34/reveal'
  ]

  put = [
      '/v1/app_store/applications/3/hide',
      '/v1/persons/4',
      '/v1/organizations/54/subsidiary_offers/34/confirm'
  ]

  delete = [
      '/v1/organizations/33/friends/23',
      '/v1/organizations/44/movies/45',
      '/v1/organizations/34/market/products/54/properties/4'
  ]

  router = Endive::Routing::Mapping::Mapper.instance.router
  puts msg
  Benchmark.bm do |x|
    x.report do
      1000.times do
        get.each do |path|
          router.find_route 'get', path
        end

        post.each do |path|
          router.find_route 'post', path
        end

        put.each do |path|
          router.find_route 'put', path
        end

        delete.each do |path|
          router.find_route 'delete', path
        end
      end
    end
  end
end

test_router(Endive::Routing::Journey::SimpleRouter, 'testing simple router')
test_router(Endive::Routing::Journey::TreeRouter::Router, 'testing tree router')
