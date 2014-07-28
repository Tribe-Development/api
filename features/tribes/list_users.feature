Feature: List all users of a tribe
    In order to verify that we can list users of a tribe
    As a user
    I should be able to list all users of a tribe that I belong to
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
        And I list all the users in the tribe Fellowship
        Then I should see the JSON response:
            """
            {
                 "users": [
                    {
                        "username": "cyrusaf",
                        "name": "Cyrus Forbes",
                        "id": 1,
                        "image": "http://www.corporatetraveller.ca/assets/images/profile-placeholder.gif"
                    },
                    {
                        "username": "cmartell",
                        "name": "Charlie Martell",
                        "id": 2,
                        "image": "http://www.corporatetraveller.ca/assets/images/profile-placeholder.gif"
                    }
                 ] 
            }
            """