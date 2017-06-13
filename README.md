# Certbot & Heroku SSL Renewal Script

A shell script to automate the renewal of Certbot SSL certificates and their deployment to Heroku SSL.

## Usage

(First use: Setup the Heroku app to provide a challenge endpoint, see below.)

`sudo ./renew.sh DOMAIN HEROKU_APP_NAME`

* `DOMAIN` - the main domain name of the website you wish to renew. Can be found under `/etc/letsencrypt/live`
* `HEROKU_APP_NAME` the name of the Heroku app against which the SSL certificates will be updated

e.g. `sudo ./renew.sh foobar.co.uk foo-bar-app`

Due to the opinionated directory permissions required by Certbot, this script must be run as `root`.


## Verification: ACME Challenge Endpoint

`certbot` requires the Domain to be verified via a [challenge](https://certbot.eff.org/docs/using.html#manual) by HTTP request (or DNS lookup). The Heroku app must respond to these endpoint requests during verification.

A request might look like this:<br/>`GET /.well-known/acme-challenge/-fWyC20cYj2QO6CrrdfJ5RkCEM5RHMExcuVP2WojRIk`<br/>

And should return a verification code like:<br/>`-fWyC20cYj2QO6CrrdfJ5RkCEM5RHMExcuVP2WojRIk.rJ8qm6vdIGyqtJLe8wjza8o4IpwobjKCv3M9Z5Yuyi0`

To accomplish this, this script sets three [Heroku environment variables](https://devcenter.heroku.com/articles/config-vars) via the Heroku CLI: 

* `ACME_ENABLED` = `1` or `0` (on or off)
* `ACME_URL` = the request token
* `ACME_RESPONSE` = the response string

After the renewal `ACME_ENABLED` is set to `0`.

The Heroku app therefore *must implement* reading the environment variables and responding to requests at  `/.well-known/acme-challenge/` correctly. The endpoint does only need to be available during the verification; it can be toggled via `ACME_ENABLED`.
