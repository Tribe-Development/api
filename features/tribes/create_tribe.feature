Feature: Create a tribe and add creator to it
    In order to verify that tribe creation works
    As a user
    I should be able to create a tribe
     Scenario:
        Given the following users exist:
            | username | password | first_name | last_name |
            | cyrusaf  | bugzzues | Cyrus      | Forbes    |
        And I am logged in as user cyrusaf with password bugzzues
        And table tribes is empty
        And table tribe_to_users is empty
        When I create a new tribe called Fellowship
        Then a tribe called Fellowship should exist
        And I should be a part of the tribe Fellowship