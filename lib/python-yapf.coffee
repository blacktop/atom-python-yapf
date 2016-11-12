fs = require 'fs-plus'
$ = require 'jquery'
process = require 'child_process'
hasbin = require 'hasbin'

module.exports =
class PythonYAPF
  statusDialog: null

  isPythonContext: (editor) ->
    if not editor?
      return false
    return editor.getGrammar().scopeName == 'source.python'

  setStatusDialog: (dialog) ->
    @statusDialog = dialog

  removeStatusbarItem: ->
    @statusBarTile?.destroy()
    @statusBarTile = null

  updateStatusbarText: (message, success) ->
    @statusDialog.update message, success

  getFilePath: ->
    return atom.workspace.getActiveTextEditor().getPath()

  checkCode: ->
    @runYapf 'check'

  formatCode: ->
    @runYapf 'format'

  runYapf: (mode) ->
    if not @isPythonContext atom.workspace.getActiveTextEditor()
      return

    yapfPath = fs.normalize atom.config.get 'python-yapf.yapfPath'
    if not fs.existsSync(yapfPath) and not hasbin.sync(yapfPath)
      @updateStatusbarText 'unable to open ' + yapfPath, false
      return

    if mode == 'format'
      @updateStatusbarText '⧗', true
      params = [@getFilePath(), '-i']
    else if mode == 'check'
      params = [@getFilePath(), '-d']
    else
      return

    yapfStyle = atom.config.get 'python-yapf.yapfStyle'
    if yapfStyle.length
      params = params.concat ['--style', yapfStyle]

    proc = process.spawn yapfPath, params
    output = []
    proc.stdout.setEncoding 'utf8'
    proc.stdout.on 'data', (chunk) ->
      output.push chunk
    proc.stdout.on 'end', (chunk) ->
      output.join()
    proc.on 'exit', (exit_code, signal) =>
      if ((mode == 'check' and exit_code != 0) or
          (mode == 'format' and exit_code == 1))
        @updateStatusbarText 'x', false
      else
        @updateStatusbarText '√', true
