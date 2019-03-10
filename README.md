# 2019.elm-conf.com

The plan:

- parse all the elm-markup docs to find slugs and stuff. Make a routing tree.
- re-parse all the elm-markup docs to validate properties about them (all valid markup, valid links, etc) Also transform internal links here based on the routing tree we have!
- make nice rendering errors if stuff goes wrong there
- grab these docs by content hash
- prerender pages rendered by each doc
