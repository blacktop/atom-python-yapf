PythonYAPF = require './python-yapf'

module.exports =
  config:
    yapfPath:
      type: 'string'
      default: 'yapf'
    yapfStyle:
      type: 'string'
      default: ''
    formatOnSave:
      type: 'boolean'
      default: false
    checkOnSave:
      type: 'boolean'
      default: true

  activate: ->
    pi = new PythonYAPF()

    atom.commands.add 'atom-workspace', 'pane:active-item-changed', ->
      pi.removeStatusbarItem()

    atom.commands.add 'atom-workspace', 'python-yapf:formatCode', ->
      pi.formatCode()

    atom.commands.add 'atom-workspace', 'python-yapf:checkFormat', ->
      pi.checkFormat()

    atom.config.observe 'python-yapf.formatOnSave', (value) ->
      atom.workspace.observeTextEditors (editor) ->
        if value == true
          editor._yapfFormat = editor.onDidSave -> pi.formatCode()
        else
          editor._yapfFormat?.dispose()

    atom.config.observe 'python-yapf.checkOnSave', (value) ->
      atom.workspace.observeTextEditors (editor) ->
        if value == true
          editor._yapfCheck = editor.onDidSave -> pi.checkFormat()
        else
          editor._yapfCheck?.dispose()
