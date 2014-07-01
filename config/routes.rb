Rails.application.routes.draw do

  root 'welcome#index'
  get '/sports-design' => 'welcome#sports_design'
  get '/industrial' => 'welcome#industrial'
  get '/philosophy' => 'welcome#philosophy'

end
