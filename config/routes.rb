Panda::Application.routes.draw do

  match 'upload_form' => 'videos#upload_form'
  match 'api/videos' => 'videos#upload_via_api'
  match 'videos/form' => 'videos#upload_form'
  match 'signup' => 'accounts#new'
  match 'login' => 'auth#login'
  match 'logout' => 'auth#logout'

  root :to => 'dashboard#index'

end
