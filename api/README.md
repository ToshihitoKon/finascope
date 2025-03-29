# Finascope API

- Grape
- Rack

## Execute for development

```shell
$ bundle install
$ bundle exec rerun -- rackup
```

## Path

- /api
    - /v1
        - /records
            - GET
            - POST
        - /records/:id
            - PUT
            - DELETE
        - /categories
            - GET
            - POST
        - /categories/:id
            - PUT
            - DELETE
        - /methods
            - GET
            - POST
        - /methods/:id
            - PUT
            - DELETE
