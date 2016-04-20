# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
Rails.application.config.assets.precompile += %w( bootstrap-select/bootstrap-select.js )
Rails.application.config.assets.precompile += %w( bootstrap-select/bootstrap-select.css )

# assets for drawing visualizations
Rails.application.config.assets.precompile += %w( draw/include.css )
Rails.application.config.assets.precompile += %w( draw/include.js )
Rails.application.config.assets.precompile += %w( draw/sunburst.js )
Rails.application.config.assets.precompile += %w( draw/stacked-bar.js )
Rails.application.config.assets.precompile += %w( draw/normalized-stacked-bar.js )
Rails.application.config.assets.precompile += %w( draw/sankey.js )

# assets for material design sharing button
Rails.application.config.assets.precompile += %w( mfb/mfb.min.js )
Rails.application.config.assets.precompile += %w( mfb/mfb.min.css )
Rails.application.config.assets.precompile += %w( mfb/mfb.css.map )

# assets for welcome
Rails.application.config.assets.precompile += %w( welcome/landing-page.css )