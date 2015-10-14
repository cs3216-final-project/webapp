####Setup Instructions:

This is built on Sinatra and backboneJS.

 - Clone the repo
 - Install `npm`, `gulp`, `bundler`, `ruby-2.2.2`, `sqlite3` and `rerun`
 - Copy `config.coffee.example` into `config.coffee`
 - Copy `config/database.yml.example` into `config/database.yml`
 - Copy `.env.example` into `.env`
 - `bundle install`
 - `rake db:migrate`
 -  `npm install`
 - `gulp` . This compiles coffeescript and Handlebars Templates, minifies JS/CSS, watches any changes to the source files and rebuilds them.
 - In a new tab on the terminal, `rerun 'rackup -p 4000'` (including the quotes)
 - Navigate to `localhost:4000`

####Development Specific:
It's recommended to install EditorConfig for your editor to maintain consistent coding styles.

For ST3: https://packagecontrol.io/packages/EditorConfig
