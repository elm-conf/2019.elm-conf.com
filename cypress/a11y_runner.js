describe('Accessibility', function() {
  URLS.split('\n').forEach(function(url) {
    if (url.trim() === '') return;

    describe(url, function() {
      it('has no detectable a11y violations on page load', function() {
        // set up routing for the markdown file
        cy.visit(url);

        // wait for an H1 to be rendered after Elm gets the markdown content
        cy.get('h1');

        // do accessibility test
        cy.injectAxe();
        cy.checkA11y();
      });

      it('has a working skip to content link', function() {
        // wait for XHR
        cy.visit(url);
        cy.get('h1');

        // do tab navigation on the keyboard. The click has to be forced because
        // of some quirk in Cypress' runner.
        cy.tab();
        cy.focused().click({ force: true });

        // assert
        cy.get('main').then(function(mainQuery) {
          var main = mainQuery[0];
          cy.hash().should('eq', '#' + main.id);
          cy.focused().should('eq', main);
        });
      });
    });
  });
});
