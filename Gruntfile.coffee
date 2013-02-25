
module.exports = (grunt) ->

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  # grunt.loadNpmTasks 'grunt-reload'

  grunt.initConfig
    connect:
      server:
        options:
          port: 8000
    coffee:
      compile:
        files:
          "page/main.js": "action/main.coffee"
      options:
        bare: yes
        watch: yes
    jade:
      compile:
        options:
          data:
            debug: no
          pretty: yes
        files:
          "page/index.html": "layout/index.jade"
    stylus:
      compile:
        options: {}
        files:
          "page/page.css": "layout/page.styl"
    # reload:
    #   port: 6001
    #   proxy:
    #     host: "localhost"
    watch:
      coffee:
        files: "action/*.coffee"
        tasks: "coffee"
      stylus:
        files: "layout/*styl"
        tasks: "stylus"
      jade:
        files: "layout/*.jade"
        tasks: "jade"
      # reload:
      #   files: "page/*"
      #   tasks: "reload"

  # grunt.registerTask "dev", ["reload", "watch"]
  grunt.registerTask "dev", ["connect:server", "watch"]