# Forbidden Lands RPG Companion App

Welcome to the Forbidden Lands RPG Companion App documentation! This repository hosts a personal project aimed at enhancing your experience while playing the thrilling role-playing game [Forbidden Lands](https://freeleaguepublishing.com/en/games/forbidden-lands/). Whether you're a player or a Game Master (GM), this app is designed to enrich your sessions and streamline certain aspects of gameplay.

# About the Project

This project is created with a passion for the Forbidden Lands universe. While it's not intended to be a fully-integrated GM companion, it serves as a valuable tool to aid GMs and players alike in various aspects of the game.

## Contributions

Contributions to this project are more than welcome! If you're interested in adding your expertise and insights, please ensure that your contributions align with the project's guidelines. Let's work together to make this app a fantastic resource for the Forbidden Lands community.

## Features

During your Forbidden Lands RPG sessions, the app shines as a versatile tool:
- Manage View for GMs: Keep track of game time, set the perfect ambiance with background music, and manage stronghold resources to enhance the immersive experience.
- Dashboard View for Players: For players, the app provides a comprehensive map view and the ability to immerse themselves in the ambiance. This view is ideally suited for projection using a beamer, making your game world come to life.

Beyond the tabletop sessions:
- Event Tracking: Easily record and keep track of events that unfold throughout your campaign. Stay organized and never miss a pivotal moment.
- Event Browsing: Browse through past events, reminisce about your adventures, and use this feature as a reference for your ongoing gameplay.

# Installation

This project uses [Elixir](https://elixir-lang.org/) and the [web framework Phoenix/LiveView](https://www.phoenixframework.org/).

## Minimal Setup

To get started, follow these steps:

- Install dependencies with `mix deps.get`.
- Create and migrate your database with `mix ecto.setup`. Make sure you have PostgreSQL installed and configured. Default configuration for the development environment can be found in `config/dev.exs`.
- Start the Phoenix endpoint with `mix phx.server` or within IEx using `iex -S mix phx.server`.

You can access the app by visiting [`localhost:4000`](http://localhost:4000) in your browser.

## Adding Music Playlists

Please note that due to copyright issues, no music files are provided. You can set up your own playlist:

1. Create a `musics` folder within the `priv/static` directory.
2. Inside the `musics` folder, create subdirectories for each playlist. The name of each subdirectory will be the name of the playlist.
3. Place your MP3 files within these subdirectories to represent the music for each playlist.

After setting up your playlist folders, run the following mix command to generate the `mood.txt` file:

```bash
mix fl.process_playlists [input_directory] [output_file]
```

## Accessing the Admin Panel

During development, the admin username is `admin`, and the admin password is `1234`. You can modify these credentials in the `config/dev.exs` file as shown below:
``` elixir
# User and password for admin auth
config :forbidden_lands,
  username: "admin",
  password: "1234"
```

# Production

If you intend to deploy the app, please refer to the [official Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

However, the app is already configured for fast deployment on [fly.io](https://fly.io/).

## Admin Panel Access in Production

During deployment, you'll need to set environment variables to access the admin panel. Here's an example of how to do it for fly.io:
``` bash
fly secrets set ADMIN_USERNAME={some_user}
fly secrets set ADMIN_PASSWORD={some_password}
```
