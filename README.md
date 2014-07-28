# REST API Documentation

# Login / Signup

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

##### Body
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

##### Body
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