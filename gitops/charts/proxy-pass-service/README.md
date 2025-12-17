# proxy-pass-service

This chart lets us easily control where traffic to this application goes. This is useful during migration.

Depending on `.values.target`, this application can route traffic to three different targets. See below:

Visually showing the routing targets below, these are "interna", "external", or "static":

```plain
  traffic
    |
    v
  ingress -> internal service
    |
    v
  service
    |
    v
  nginx   -> external service
    |
    v
  static
```
