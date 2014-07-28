# REST API Documentation

# Login / Signup
### POST /users/new
#### Parameters
```json
{
    username:   string,
    password:   string,
    first_name: string,
    last_name:  string
}
```

#### Body
```json
{
    token: integer
}
```
===

### POST /login
#### Parameters
```json
{
    username:   string,
    password:   string
}
```

#### Body
```json
{
    token: integer
}
```