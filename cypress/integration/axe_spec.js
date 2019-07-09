describe('Accessibility', function() {
  describe('/', function() {
    it('has no detectable a11y violation on load', function () {
      cy.visit('/');
      cy.injectAxe();
      cy.checkA11y();
    });
  });
});
