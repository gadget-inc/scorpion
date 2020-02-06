describe("Logins", function() {
  beforeEach(() => {
    cy.emptyAccount();
  });

  it("can log in", function() {
    cy.visit("/");
    cy.get("#email").type("cypress@gadget.dev")
    cy.get("#password").type("incorrect")

    cy.get("[data-test-id=login-submit]").click()
    cy.contains("Invalid Email")

    cy.get("#password").clear().type("secrets")
    cy.get("[data-test-id=login-submit]").click()
    cy.contains("Scorpion")
  });
});
