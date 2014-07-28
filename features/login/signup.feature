Feature: Sign up a new user and log them in
    In order to verify that user signup and login works
    As a new user
    I should be able to create an account and login with it
    Scenario:
        Given table users is empty
        And table sessions is empty
        When I submit a form called signup with username cyrusaf and password bugzzues
        Then I can login with username cyrusaf and password bugzzues