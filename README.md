# Postal plugin for Discourse

Provides a simple endpoint for [Postal](https://github.com/postalhq/postal) to deliver inbound emails to Discourse

## Getting Started

You should install the plugin via the current Discourse plugin instructions - https://meta.discourse.org/t/install-a-plugin/19157

### Prerequisites

You will require a Postal instance, with a configured domain, HTTP endpoint, and routing to the endpoint.

The important bits of the HTTP endpoint settings are:
- **encoding**: _Sent in the body as JSON_
- **format**: _Delivered as a hash_ (not _that_ kind of hash delivery...)

### Installing

Installing this plugin should be as simple as following the [Discourse Plugin installation tutorial](https://meta.discourse.org/t/install-a-plugin/19157)

## Running the tests

_Note: I didn't setup these tests when I adapted the plugin from the mailgun one, they probably don't work out the box... _

In order to run tests you'll need a Discourse development environment such as the [vagrant](https://github.com/discourse/discourse/blob/master/docs/VAGRANT.md) one.

You can then run the tests with `rake plugin:spec[discourse-postal]`

## Deployment

Once the plugin is installed, you'll need to configure a few things:

* Postal webhook public key - I can't remember where I had to get this from...
* Discourse Base URL - the URL where your discourse is available
* Discourse API key - you can create one in the discourse admin panel
* Discourse API username

You can do this in the plugin settings page.

You'll also need to enable "manual polling enabled" in your discourse email settings admin panel.

Once that is done, you need to configure Postal your postal routing to forward messages to `http://your-discourse-url/postal/incoming`

## Built With

* [Atom](https://atom.io) - The editor used
* [Ruby on Rails](http://rubyonrails.org) - Application framework
* [Discourse Plugins](https://meta.discourse.org/t/beginners-guide-to-creating-discourse-plugins-part-1/30515) - Plugin framework for Discourse

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/PurpleBooth/b24679402957c63ec426) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [SemVer](http://semver.org/) for versioning. For the versions available, see the [tags on this repository](https://github.com/reallyreally/discourse-mailgun/tags). 

## Authors

* **Tiago Macedo** - *Initial work* - [Really Really Inc](https://really.ai/)
* **Nick Sellen** - *Adapted mailgun plugin to work for postal* - [nicksellen.co.uk](https://nicksellen.co.uk/)

See also the list of [contributors](https://github.com/nicksellen/discourse-postal/contributors) who participated in this project.

## License

This project is licensed under the Apache 2.0 - see the [LICENSE.md](LICENSE.md) file for details
