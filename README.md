# CLOCOSS PaaS Based API

## How to use
```
git clone https://github.com/Ollie1700/clocoss-paas-based-api
cd clocoss-paas-based-api
npm install
node server
```

## API
| Method  | Endpoint            | Usage                                                    | Returns |
| ------- | ------------------- | -------------------------------------------------------- | ------- |
| `GET`   | `/api/{id}`         | Get the count                                            | `200`: `{ id, count }` `404`: Count `{id}` `500`: Server error |
| `POST`  | `/api/{id}`         | Create a new count                                       | `200`: `{ id, count }` `404`: Count `{id}` doesn't exist `500`: Server error |
| `POST`  | `/api/{id}/{count}` | Create a new count starting at {count},<br/>
                                  or if {id} already exists, add {count} to existing count | `200`: `{ id, count }` `404`: Count `{id}` doesn't exist `500`: Server error |
| `PUT`   | `/api/{id}`         | Reset an existing count to 0                             | `200`: `{ id, count }` `404`: Count `{id}` doesn't exist `500`: Server error |
| `PUT`   | `/api/{id}/{count}` | Override an existing count to {count}                    | `200`: `{ id, count }` `404`: Count `{id}` doesn't exist `500`: Server error |
| `DELETE`| `/api/{id}`         | Delete a count                                           | `204`: Delete successful `404`: Count `{id}` doesn't exist `500`: Server error |
