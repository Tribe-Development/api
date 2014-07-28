Feature: Create a tribe and add creator to it
    In order to verify that a user can be added to a tribe
    As a user
    I should be able to add another user to a tribe that I belong to
     Scenario:
        Given the following users exist:
            | username | password | first_name | last_name |
            | cyrusaf  | bugzzues | Cyrus      | Forbes    |
            | cmartell | password | Charlie    | Martell   |
        And I am logged in as user cyrusaf with password bugzzues
        And table tribes is empty
        And table tribe_to_users is empty
        When I create a new tribe called Fellowship
        And I add user cmartell to the tribe Fellowship
        Then the user cmartell should be a part of the tribe Fellowship