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

        // do tab navigation on the keyboard.
        cy.tab();
        cy.focused().click();

        // assert
        cy.get('main').then(function(mainQuery) { cy.hash().should('eq', '#' + mainQuery[0].id); });
        cy.get('main').should('be.focused');
      });
    });
  });
});
