{spawn, exec} = require 'child_process'

launch = (cmd, options=[], done=null) ->
    app = spawn cmd, options
    app.stdout.pipe(process.stdout)
    app.stderr.pipe(process.stderr)
    app.on 'exit', (status) ->
        err = if status isnt 0 then new Error("Error running #{cmd}") else null
        done? err

build = (done) ->
    console.log "Building"
    exec 'node_modules/.bin/coffee --compile --output lib/ src/', (err, stdout, stderr) ->
        process.stdout.write stdout
        process.stderr.write stderr
        return done err if err

        console.log "Built"
        done?()

mocha = (done) ->
    console.log "Testing"

    options = []
    options.push '--compilers'
    options.push 'coffee:coffee-script/register'

    # Colors!
    options.push '-c'

    # Run everything in the `test` folder.
    options.push '--recursive'
    options.push 'test'

    options.push '--reporter'
    options.push 'spec'

    launch './node_modules/.bin/mocha', options, done

run = (fn) ->
    ->
        fn (err) ->
            console.log err.stack if err

task 'build', "Build project from src/*.coffee to lib/*.js", run build
task 'test', "Run mocha tests", run -> build mocha
