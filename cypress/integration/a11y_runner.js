describe('Accessibility', function() {
  URLS.split('\n').forEach(function(url) {
    describe(url, function() {
      it('has no detectable a11y violations on page load', function() {
        // set up routing for the markdown file
        cy.visit(url);

        // wait for an H1 to be rendered after Elm gets the markdown content
        cy.get('h1');

        // do accessibility test
        cy.injectAxe();
        cy.configureAxe({
          rules: [
            {
              // TODO: I would love to only turn it off for our primary brand color?
              id: "color-contrast",
              enabled: false,
            }
          ]
        });
        cy.checkA11y();
      });
    });
  });
});
