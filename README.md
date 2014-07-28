# REST API Documentation

## Contents
**1. Login**
* [Create a new user](#post-usersnew)
* [Login a user](#post-login)
* [Logout a user](#post-logout)

**2. Tribes**
* [Create a new tribe](#post-tribesnew)
* [Add a user to a tribe](#post-tribestribe_idaddusersuser_id)
* [Get a list of all users that are a part of a tribe](#get-tribestribe_idusers)

===

### 1. Login

#### POST /users/new
Creates a new user
###### Parameters
```javascript
{
    username:   string,
    password:   string,
    first_name: string,
    last_name:  string
}
```

###### Body
```javascript
{
    token: integer
}
```
===

#### POST /login
Creates a new sessions and returns the session token
###### Parameters
```javascript
{
    username:   string,
    password:   string
}
```

###### Body
```javascript
{
    token: integer
}
```
===

#### POST /logout
Destroys the current session
###### Parameters
```javascript
{
    token: string
}
```
===
### 2. Tribes

#### POST /tribes/new
Create a new tribe and add creator to it
###### Parameters
```javascript
{
    name:   string,
    token:   string
}
```
===

#### POST /tribes/:tribe_id/add/users/:user_id
Adds user to said tribe. FRIEND AUTHENTICATION NEEDS TO BE ADDED!

###### Parameters
See URL...
===
#### GET /tribes/:tribe_id/users
Get a list of all users in a tribe

###### Parameters
```javascript
{
    token: string
}
```

###### Body
```javascript
{
    users: [
        {
            username: string,
            name: string,
            id: integer,
            image: string (url)
        },
        ...
    ]
}
```