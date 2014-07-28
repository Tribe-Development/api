# REST API Documentation

## Contents
**1. Login**
* Create a new user
* Login a user
* Logout a user
**2. Tribes**
* Create a new tribe *

## 1. Login

### POST /users/new
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

### POST /login
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

### POST /logout
Destroys the current session
###### Parameters
```javascript
{
    token: string
}
```

## 2. Tribes

### POST /tribes/new
Create a new tribe
###### Parameters
```javascript
{
    name:   string,
    token:   string
}
```

###### Body
```javascript
{
    token: integer
}
```