fs     = require 'fs'
path   = require 'path'
AdmZip = require 'adm-zip'
async  = require 'async'
mkdirp = require 'mkdirp'

TOP_ZIP_RE = /._ORDER_.*\.zip/
ZIPPED_BOOK_RE = /^._(.*)\.zip/

mkdir = (dir) -> mkdirp.sync dir

endsWith = (str, suffix) ->
    return str.indexOf(suffix, str.length - suffix.length) != -1

zipFileToBookName = (fileName) ->
    match = fileName.match ZIPPED_BOOK_RE
    if match?
        return match[1].split("_").join(" ")
    else
        return null

# Finds all the X_ORDER_XXXX.zip files in `orderDir` and extracts them.
#
# Parameters:
# * `orderDir` is the folder to search for zip files.
# * `options.outputPath` is a folder to write extracted books into.
#   Defaults to "#{orderDir}/extracted".
# * `options.verbose` to write verbose output (TODO: This should really
#   use a listener pattern or something.)
#
extractOrders = (orderDir, options={}) ->
    log = (level, args...)->
        if level is 'debug'
            console.log args... if options.verbose
        else
            console.log args...

    dest = options.outputPath
    if !dest?
        dest = path.resolve(orderDir, 'extracted')
        mkdir dest
    log 'info', "Extracting to #{dest}"

    log 'debug', "Looking for order zip files in #{orderDir}"
    files = fs.readdirSync(orderDir)

    fileProcessor = (file, done) ->
        if TOP_ZIP_RE.test file
            log 'info', "Extracting from #{file}"
            extractOrder path.resolve(orderDir, file), dest, log, done
        else done()

    async.eachSeries files, fileProcessor, (err) ->
        return log 'error', err if err
        log 'debug', "Done"

# This is an older version of extractOrder based on
# [unzip](https://github.com/EvanOxfeld/node-unzip), but at the time of this
# writing, unzip has some bugs in it that stop it from working.

# extractOrder = (orderZip, dest, log, done) ->
#     zip = fs.createReadStream(orderZip).pipe(unzip.Parse())
#     zip.on 'error', (err) ->
#         console.log "Error while reading #{orderZip}", err
#         done err
#
#     zip.on 'entry', (entry) ->
#         fileName = entry.path
#         bookName = zipFileToBookName(fileName)
#         if entry.type is 'File' and bookName?
#             destFolder = path.resolve dest, bookName
#             mkdir destFolder
#
#             if fileName[0] is 'H'
#                 # Write the file to the correct dir
#                 destFile = path.resolve destFolder, "#{bookName} HTML.zip"
#                 console.log "  Writing #{destFile}"
#                 entry.pipe fs.createWriteStream(destFile)
#             else
#                 console.log "  Extracting to #{destFolder}"
#                 entry.pipe(unzip.Extract({path: destFolder}))
#
#     zip.on 'end', done

# Extract an order zip file into a destination directory.
extractOrder = (orderZip, dest, log, done) ->
    zip = new AdmZip(orderZip)
    zip.getEntries().forEach (entry) ->
        fileName = entry.entryName
        bookName = zipFileToBookName(fileName)
        if !entry.isDirectory and bookName?
            destFolder = path.resolve dest, bookName
            mkdir destFolder

            if fileName[0] is 'H'
                # Write the file to the correct dir
                destFile = path.resolve destFolder, "#{bookName} HTML.zip"
                log 'debug', "  Writing #{destFile}"
                zip.extractEntryTo entry, destFile, true, true
            else
                log 'debug', "  Extracting to #{destFolder}"
                entryBuffer = zip.readFile(entry)
                entryZip = new AdmZip(entryBuffer)
                entryZip.extractAllTo destFolder, true
    done()


parseArguments = ->
    ArgumentParser = require('argparse').ArgumentParser

    parser = new ArgumentParser
        addHelp: true
        description: """
            Search a folder for Baen ZIP files (e.g. E_ORDER_23023.zip)
            and extract all books into subdirectories.
            """

    parser.addArgument [ '--verbose' ],
        help: "Verbose output."
        nargs: 0
        action: 'storeTrue'

    parser.addArgument [ '--out', '-o' ],
        help: "Folder to write output to."
        nargs: 1

    parser.addArgument [ 'folder' ],
        help: "Folder or folders to examine."
        nargs: 1

    return parser.parseArgs()

main = ->
    args = parseArguments()

    inputPath = path.resolve args.folder[0]
    outputPath = if args.out?[0]? then path.resolve(args.out[0]) else null
    verbose = args.verbose

    extractOrders inputPath, {outputPath, verbose}

main()
