describe('Accessibility', function() {
  URLS.split('\n').forEach(function(url) {
    describe(url, function() {
      it('has not detectable a11y violations on page load', function() {
        cy.visit(url);
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
