pagerduty-lognotifier
=====================

A gem to monitor multiple log files and trigger alerts to pagerduty when specific patterns are match

## Installation

Install it yourself as:

    $ gem install lognotifier

## Usage

Config file example:

```
---
logfile: '/var/log/lognotifier.log'
pagerduty:
  '/var/log/syslog':
    servicekey: 'XXXXXXX'
    patterns: 
      - regex: 'error1'
        prefix: 'This is a errror' 
      - regex: 'error2.*pattern'
        prefix: 'This is another test' 
  '/var/log/example':
    servicekey: 'XXXXXXX'
    patterns: 
      - regex: 'asdf'
        prefix: 'This is a asdf error' 
      - regex: 'dfsa'
        prefix: 'This is another dfsa error' 


```

Run it:

```
$ lognotifierd

```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/lognotifier/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
