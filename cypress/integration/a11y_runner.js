describe('Accessibility', function() {
  URLS.split('\n').forEach(function(url) {
    describe(url, function() {
      it('has not detectable a11y violations on page load', function() {
        cy.visit(url);
        cy.injectAxe();
        cy.checkA11y();
      });
    });
  });
});
