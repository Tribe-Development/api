Feature: Sign up a new user
    Scenario:
        Given table users is empty
        When I submit a form called signup with username cyrusaf and password bugzzues
        Then I can login with username cyrusaf and password bugzzues