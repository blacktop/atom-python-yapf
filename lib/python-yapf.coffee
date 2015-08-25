fs = require 'fs'
$ = require 'jquery'
process = require 'child_process'

module.exports =
class PythonYAPF

  checkForPythonContext: ->
    editor = atom.workspace.getActiveTextEditor()
    if not editor?
      return false
    return editor.getGrammar().name == 'Python'

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

    yapfPath = atom.config.get('python-yapf.yapfPath')
    yapfStyle = atom.config.get('python-yapf.yapfStyle')
    params = [@getFilePath(), "-d"]
    if yapfStyle.length
      params = params.concat ["--style", yapfStyle]
    which = process.spawnSync('which', ['yapf']).status
    if which == 1 and not fs.existsSync(yapfPath)
      @updateStatusbarText("unable to open " + yapfPath, false)
      return

    proc = process.spawn yapfPath, params

    updateStatusbarText = @updateStatusbarText
    yapf_out = []
    proc.stdout.setEncoding('utf8')
    proc.stdout.on 'data', (chunk) ->
      yapf_out.push(chunk)
    proc.stdout.on 'end', (chunk) ->
      yapf_out.join()
    proc.on 'exit', (exit_code, signal) ->
      if yapf_out.length == 0
        updateStatusbarText("√", false)
      else
        updateStatusbarText("x", true)

  formatCode: ->
    if not @checkForPythonContext()
      return

    yapfPath = atom.config.get('python-yapf.yapfPath')
    yapfStyle = atom.config.get('python-yapf.yapfStyle')
    params = [@getFilePath(), "-i"]
    if yapfStyle.length
      params = params.concat ["--style", yapfStyle]
    which = process.spawnSync('which', ['yapf']).status
    if which == 1 and not fs.existsSync(yapfPath)
      @updateStatusbarText("unable to open " + yapfPath, false)
      return

    proc = process.spawn yapfPath, params
    @updateStatusbarText("√", false)
    @reload
