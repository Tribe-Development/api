# REST API Documentation

# Login / Signup
### POST /users/new
##### Parameters
```json
{
    username:   string,
    password:   string,
    first_name: string,
    last_name:  string
}
```

##### Body
```json
{
    token: integer
}
```
===

### POST /login
##### Parameters
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