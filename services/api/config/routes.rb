Rails.application.routes.draw do
  # Health check endpoint
  get "up" => "rails/health#show", as: :rails_health_check

  # Public routes (no authentication required)
  scope :public do
    # Registration and role endpoints
    # POST /public/register
    post "register", to: "user_registrations#register"
    # GET /public/admin_roles
    get "admin_roles", to: "access_roles#admin_roles"
    # GET /public/employee_roles
    get "employee_roles", to: "access_roles#employee_roles"
  end

  # Authentication routes
  get "login", to: "sessions#new", as: :login
  post "login", to: "sessions#create", as: :create_session
  delete "logout", to: "sessions#destroy", as: :logout
  get "select_company", to: "sessions#select_company_form", as: :select_company
  post "set_company", to: "sessions#set_company", as: :set_company_session


  post "create_company", to: "companies#create"

  # Authenticated routes
  get "me", to: "user_profiles#show"

  # Company management routes
  resources :user_profiles, only: [:create, :update] do
    member do
      patch :activate
    end
  end

  resources :companies, only: [:index, :show, :update] do
    resource :bank_config do
      # GET /companies/:company_id/bank_config/new
      # GET /companies/:company_id/bank_config/edit
      # GET /companies/:company_id/bank_config
      # POST /companies/:company_id/bank_config
      # PATCH/PUT /companies/:company_id/bank_config
      # DELETE /companies/:company_id/bank_config
    end

    resource :company_union_configuration do
      # GET /companies/:company_id/company_union_configuration/new
      # GET /companies/:company_id/company_union_configuration/edit
      # GET /companies/:company_id/company_union_configuration
      # POST /companies/:company_id/company_union_configuration
      # PATCH/PUT /companies/:company_id/company_union_configuration
      # DELETE /companies/:company_id/company_union_configuration
    end

    resource :payroll_config do
      # GET /companies/:company_id/payroll_config/new
      # GET /companies/:company_id/payroll_config/edit
      # GET /companies/:company_id/payroll_config
      # POST /companies/:company_id/payroll_config
      # PATCH/PUT /companies/:company_id/payroll_config
      # DELETE /companies/:company_id/payroll_config
    end

    resources :company_members do
      # GET /companies/:company_id/company_members/new
      # GET /companies/:company_id/company_members/:id/edit
      # GET /companies/:company_id/company_members/:id
      # POST /companies/:company_id/company_members
      # PATCH/PUT /companies/:company_id/company_members/:id
      # DELETE /companies/:company_id/company_members/:id
    end

    resources :addresses

    member do
      # POST /companies/:id/submit_for_review
      post :submit_for_review
      # GET /companies/:id/review_status
      get :review_status
    end
  end

  # Company review routes (admin only)
  # GET /company_reviews - List all company reviews
  # GET /company_reviews/:id - Show a specific company review
  # PATCH/PUT /company_reviews/:id - Update a company review
  # PATCH /company_reviews/:id/approve - Approve a company review
  # PATCH /company_reviews/:id/reject - Reject a company review
  resources :company_reviews, only: [:index, :show, :update] do
    member do
      patch :approve
      patch :reject
      get :review_status
    end
  end

  # File upload endpoints
  post "/uploads/presigned_url", to: "uploads#presigned_url"
end
