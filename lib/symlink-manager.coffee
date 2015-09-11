SymlinkManagerView = require './symlink-manager-view'
{CompositeDisposable} = require 'atom'

module.exports = SymlinkManager =
  symlinkManagerView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @symlinkManagerView = new SymlinkManagerView(state.symlinkManagerViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @symlinkManagerView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'symlink-manager:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @symlinkManagerView.destroy()

  serialize: ->
    symlinkManagerViewState: @symlinkManagerView.serialize()

  toggle: ->
    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
