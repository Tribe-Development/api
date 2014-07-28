Feature: Logout
    In order to verify that a session is destroyed when a user logs out
    As a logged in user
    I should be able to logout
    Scenario:
        Given the following users exist:
            | username | password | first_name | last_name |
            | cyrusaf  | bugzzues | Cyrus      | Forbes    |
        And I am logged in as user cyrusaf with password bugzzues
        When I logout
        Then my session should not exist