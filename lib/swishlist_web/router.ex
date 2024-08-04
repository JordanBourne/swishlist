defmodule SwishlistWeb.Router do
  use SwishlistWeb, :router

  import SwishlistWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {SwishlistWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SwishlistWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", SwishlistWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:swishlist, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: SwishlistWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", SwishlistWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{SwishlistWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", UserRegistrationLive, :new
      live "/users/log_in", UserLoginLive, :new
      live "/users/reset_password", UserForgotPasswordLive, :new
      live "/users/reset_password/:token", UserResetPasswordLive, :edit

      live "/guest/register/:guest_id", GuestLive.Register, :register
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", SwishlistWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{SwishlistWeb.UserAuth, :ensure_authenticated}] do
      live "/users/settings", UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", UserSettingsLive, :confirm_email

      live "/wishlist", WishlistLive, :index
      live "/wishlist/add-item", WishlistLive, :add_item
      live "/wishlist/edit-item/:item_id", WishlistLive, :edit_item

      live "/invites", GuestLive.Index, :index
      live "/invites/new", GuestLive.Index, :new
      live "/invites/:id/edit", GuestLive.Index, :edit

      live "/invites/:id", GuestLive.Show, :show
      live "/invites/:id/show/edit", GuestLive.Show, :edit

      live "/gifts", GiftLive.Index, :index
      live "/gifts/new", GiftLive.Index, :new
      live "/gifts/:id/edit", GiftLive.Index, :edit

      live "/gifts/:id", GiftLive.Show, :show
      live "/gifts/:id/show/edit", GiftLive.Show, :edit
    end
  end

  scope "/", SwishlistWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{SwishlistWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", UserConfirmationLive, :edit
      live "/users/confirm", UserConfirmationInstructionsLive, :new

      live "/wishlist/:wishlist_id", ShowWishlistLive, :index
      live "/wishlist/:wishlist_id/:guest_id", ShowWishlistLive, :guest_view
    end
  end
end
