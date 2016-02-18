fs = require 'fs-plus'
$ = require 'jquery'
process = require 'child_process'

module.exports =
class PythonYAPF

  checkForPythonContext: ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      return false
    return editor.getGrammar().scopeName == 'source.python'

  removeStatusbarItem: =>
    @statusBarTile?.destroy()
    @statusBarTile = null

  updateStatusbarText: (message, isError) =>
    if not @statusBarTile
      statusBar = document.querySelector("status-bar")
      return unless statusBar?
      @statusBarTile = statusBar
        .addLeftTile(
          item: $('<div id="status-bar-python-yapf" class="inline-block">
                    <span style="font-weight: bold">YAPF: </span>
                    <span id="python-yapf-status-message"></span>
                  </div>'), priority: 100)

    statusBarElement = @statusBarTile.getItem()
      .find('#python-yapf-status-message')

    if isError == true
      statusBarElement.addClass("text-error")
    else
      statusBarElement.removeClass("text-error")

    statusBarElement.text(message)

  getFilePath: ->
    editor = atom.workspace.getActiveTextEditor()
    return editor.getPath()

  checkFormat: ->
    if not @checkForPythonContext()
      return

    updateStatusbarText = @updateStatusbarText
    yapfPath = fs.normalize(atom.config.get('python-yapf.yapfPath'))
    yapfStyle = atom.config.get('python-yapf.yapfStyle')

    params = [@getFilePath(), "-d"]
    if yapfStyle.length
      params = params.concat ["--style", yapfStyle]

    if not fs.existsSync(yapfPath)
      @updateStatusbarText("unable to open " + yapfPath, false)
      return

    proc = process.spawn yapfPath, params

    yapf_out = []
    proc.stdout.setEncoding('utf8')
    proc.stdout.on 'data', (chunk) ->
      yapf_out.push(chunk)
    proc.stdout.on 'end', (chunk) ->
      yapf_out.join()
    proc.on 'exit', (exit_code, signal) ->
      # console.log exit_code
      if yapf_out.length or exit_code == 2
        # console.log yapf_out
        updateStatusbarText("x", true)
      else
        updateStatusbarText("√", false)

  formatCode: ->
    if not @checkForPythonContext()
      return

    updateStatusbarText = @updateStatusbarText
<<<<<<< HEAD
    updateStatusbarText('⧗', false)
    yapfPath = atom.config.get('python-yapf.yapfPath')
=======
    yapfPath = fs.normalize(atom.config.get('python-yapf.yapfPath'))
>>>>>>> master
    yapfStyle = atom.config.get('python-yapf.yapfStyle')

    proc_params = [@getFilePath(), "-i"]
    check_params = [@getFilePath(), "-d"]

    if yapfStyle.length
      proc_params = proc_params.concat ["--style", yapfStyle]
      check_params = check_params.concat ["--style", yapfStyle]

    if not fs.existsSync(yapfPath)
      updateStatusbarText("unable to open " + yapfPath, false)
      return

    proc = process.spawn yapfPath, proc_params
    proc.on 'exit', (exit_code, signal) ->
      # console.log exit_code
      @reload
      yapf_out = []
      check = process.spawn yapfPath, check_params
      check.stdout.setEncoding('utf8')
      check.stdout.on 'data', (chunk) ->
        yapf_out.push(chunk)
      check.stdout.on 'end', (chunk) ->
        yapf_out.join()
      check.on 'exit', (exit_code, signal) ->
        # console.log exit_code
        if yapf_out.length or exit_code == 2
          # console.log yapf_out
          updateStatusbarText("x", true)
        else
          updateStatusbarText("√", false)
    @reload
