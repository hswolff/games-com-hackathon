# grunt server --build=dev --domain=custom.domain.com --port=80

module.exports = (grunt) ->
  # load all grunt tasks
  require('matchdep').filterDev('grunt-*').forEach(grunt.loadNpmTasks)

  yeomanConfig = 
      dev: 'app'
      prod: 'www-build'

  yeomanConfig.appRoot = yeomanConfig[grunt.option('build')] or 'www'
  yeomanConfig.port = grunt.option('port') or 8888
  yeomanConfig.domain = (grunt.option('domain') or 'http://localhost') + ':' + yeomanConfig.port

  grunt.initConfig
      yeoman: yeomanConfig
      watch: 
          coffee: 
              files: ['<%= yeoman.dev %>/lib/game/**/*.coffee']
              tasks: ['coffee:watch']
          compass: 
              files: ['<%= yeoman.dev %>/sass/**/*.{scss,sass}']
              tasks: ['compass']
          livereload: 
              files: [
                  '<%= yeoman.dev %>/*.html',
                  '<%= yeoman.dev %>/css/**/*.css',
                  '<%= yeoman.dev %>/lib/**/*.js',
                  '<%= yeoman.dev %>/media/*.{png,jpg,jpeg}',
              ]
              tasks: ['livereload']
      open: 
          server: 
              url: '<%= yeoman.domain %>'
      # clean: 
      #     dev: ['<%= yeoman.dev %>/js/**/*.js', '!<%= yeoman.dev %>/js/vendor/**/*.js', '<%= yeoman.dev %>/css']
      #     prod: '<%= yeoman.prod %>/*'
      coffee: 
          dist: 
              expand: true
              cwd: '<%= yeoman.dev %>/lib/game'
              src: ['**/*.coffee']
              dest: '<%= yeoman.dev %>/lib/game/'
              ext: '.js'
      compass: 
          options: 
              sassDir: '<%= yeoman.dev %>/sass'
              cssDir: '<%= yeoman.dev %>/css'
              imagesDir: '<%= yeoman.dev %>/media'
              javascriptsDir: '<%= yeoman.dev %>/lib'
              # importPath: 'app/components'
              relativeAssets: true
          dist: {}
          server: 
              options: 
                  debugInfo: true

  grunt.renameTask('regarde', 'watch')
  # remove when mincss task is renamed
  grunt.renameTask('mincss', 'cssmin')

  grunt.registerTask 'coffee:watch', 'Make a server', ->
    cs = require('coffee-script')
    path = require('path')
    changedFiles = grunt.regarde.changed

    replacements = 
      'coffee': 'js'
      'sass': 'css'

    whichType = path.extname(changedFiles[0]).substr(1)

    if whichType is 'coffee'
      changedFiles.forEach (changed) ->
        fileType = path.extname(changed).substr(1)
        dirpath = path.dirname(changed).replace(fileType, replacements[fileType])
        filename = path.basename(changed).replace(fileType, replacements[fileType])

        filepath = dirpath + '/' + filename;\
        contents = cs.compile(grunt.file.read(changed))

        grunt.file.write(filepath, contents)

        grunt.log.writeln('File "' + filepath + '" created.')
    else 
      cb = this.async()
      compile(['compile', changedFiles], cb)

    #  taken from:
    #  https://github.com/gruntjs/grunt-contrib-compass/blob/master/tasks/compass.js#L15
    compile = (args, cb) -> 
      child = grunt.util.spawn
        cmd: if process.platform is 'win32' then 'compass.bat' else 'compass'
        args: args
      , (err, result, code) ->
        if code is 127
          return grunt.warn """
            You need to have Ruby and Compass installed
            and in your system PATH for this task to work.
            More info: https://github.com/gruntjs/grunt-contrib-compass
          """

        # `compass compile` exits with 1 when it has nothing to compile
        # https://github.com/chriseppstein/compass/issues/993
        cb((code is 0 or !/Nothing to compile/g.test(result.stdout)) or result.stderr)

      child.stdout.pipe(process.stdout)
      child.stderr.pipe(process.stderr)

  grunt.registerTask 'express-server', 'Make a server', ->

    express = require('express')
    impact = require('impact-weltmeister')
    port = grunt.config.get('yeoman.port')
    root = __dirname + '/app/'
    app = express()

    app.configure ->
      app.use(express.methodOverride())
      app.use(express.bodyParser())
      app.use(app.router)

    impact.listen(app, {root: root})

    app.use(express.static(root))

    app.listen(port)

    console.log('app listening on port', port);

  grunt.registerTask 'server', (target) ->
    grunt.task.run [
      'coffee:dist',
      'compass:server',
      'express-server',
      'livereload-start',
      # 'open',
      'watch' 
    ]

  grunt.registerTask 'default', ['server']