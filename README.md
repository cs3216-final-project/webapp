####Setup Instructions:

This is built on backboneJS. At this point, this is a static app. A server component with a DB will be added soon.

 - Clone the repo
 - Install `npm` and `gulp`
 - `npm install`
 - Copy `config.coffee.example` into `config.coffee`
 - `gulp` . This compiles coffeescript and Handlebars Templates, minifies JS/CSS, watches any changes to the source files and rebuilds them.
 - In a new tab on the terminal, `python -m SimpleHTTPServer`
 - Navigate to `localhost:8000`