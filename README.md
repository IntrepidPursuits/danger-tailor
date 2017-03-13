# danger-tailor

![Travis](https://travis-ci.org/IntrepidPursuits/danger-tailor.svg)
[![Coverage Status](https://coveralls.io/repos/github/IntrepidPursuits/danger-tailor/badge.svg?branch=master)](https://coveralls.io/github/IntrepidPursuits/danger-tailor?branch=master)
![MIT License](https://img.shields.io/badge/license-MIT-blue.svg)

A [Danger](http://danger.systems/) plugin that shows the static analysis output generated by [Tailor](tailor.sh).

To use this plugin, you need to generate a JSON file using [Tailor](tailor.sh) for this plugin to read.

## Installation

    $ gem install danger-tailor

## Usage

Somewhere in your build process, call tailor using the JSON output flag.

    tailor -f json MyProject/ > tailor.json

At a minimum, add this line to your `Dangerfile`:

    danger-tailor.report 'tailor.json'


You may also use optional specifiers to ignore files, or set the project root.

    # Ignore Pod warnings
    danger-tailor.ignored_files = '**/Pods/**'

    # Set a different project root
    danger-tailor.project_root = 'MyProject/NewRoot/'

## License
danger-tailor is released under the MIT license. See [LICENSE](https://github.com/IntrepidPursuits/danger-tailor/blob/master/LICENSE) for details.

## Contributing

1. Fork this repo
2. Run `bundle install` to setup dependencies.
3. Run `bundle exec rake spec` to run the tests.
4. Use `bundle exec guard` to automatically have tests run as you make changes.
5. Make your changes.
6. Create a Pull Request for us to review
