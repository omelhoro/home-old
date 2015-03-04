exports.config =
  # See docs at http://brunch.readthedocs.org/en/latest/config.html.
  files:
    javascripts:
      defaultExtension: 'coffee'
      joinTo:
        '../../javascripts/app.js': /^app/
        '../../javascripts/vendor.js': /^vendor/
      order:
        before: [
          'vendor/scripts/console-helper.js',
          'vendor/scripts/jquery-2.1.3.js',
          'vendor/scripts/underscore-1.7.0.js',
          'vendor/scripts/backbone-0.9.2.js'
        ]

    stylesheets:
      defaultExtension: 'styl'
      joinTo: '../../stylesheets/app.css'
      order:
        before: ['vendor/styles/normalize.css']
        after: ['vendor/styles/helpers.css']

    templates:
      defaultExtension: 'hbs'
      joinTo: '../../javascripts/app.js'
