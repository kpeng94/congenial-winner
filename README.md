1. Compile via `npm run build`. You may need to `sudo`. If this doesn't work, it can be compiled by separately running `npm run clean`, `npm run lint`, `npm run gulp`.
2. Run via `npm start` (if this doesn't work, you can directly run `nodemon ./server/main.coffee`).


## Directory structure
`app/`: all client side code

`--assets/`

`--coffee/`: for all Coffee files (to be compiled to JS files)

`--css/`: for all styl files (to be compiled to CSS files)

`--index.html`: for the bigscreen

`config/`: game settings / parameters

`server/`: server logic

`util/`: utility functions that could be used by frontend or backend

## Notes for development
CSS files are written as .styl files and then compiled to CSS.
JS files are written as .coffee files and then compiled to JS.

There should only be two .coffee (one for controller, one for main) files that actually get compiled to JS. The rest should be dependencies used in these two .coffee files.

This is designed as a two-page app.
