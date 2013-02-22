
module.exports = (grunt) ->

  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-jade'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-reload'

  grunt.initConfig
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
    #     port: 8000
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

  grunt.registerTask "default", ["watch", "coffee", "jade", "stylus"]

  grunt.registerTask "dev", ["watch"]