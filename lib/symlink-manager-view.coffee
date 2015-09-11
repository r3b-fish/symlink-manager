fs = require 'fs-plus'
GroupView = require './group-view'

module.exports =
class SymlinkManagerView
  config:
    defaults:
      src: "/Users/stanislavmorozov/srcfoldername"
      dst: "/Users/stanislavmorozov/Code/dstfoldername"
    groups:
      group:
        description: "Folder"
        folders:
          zw:
            url: "https://github.com/Z-Wave-Me/home-automation-ui"

  constructor: (serializedState) ->
    self = this
    # set default configuration
    if (!atom.config.get 'symlink-manager')
      atom.config.set 'symlink-manager', this.config

    # variables
    groups = atom.config.get 'symlink-manager.groups'
    defaults = atom.config.get 'symlink-manager.defaults'
    orgs = atom.config.get 'symlink-manager.orgs'
    orgSrc = atom.config.get 'symlink-manager.orgDirSrc'
    orgDest = atom.config.get 'symlink-manager.orgDirDest'

    # Create root element
    @element = document.createElement 'div'
    @element.classList.add 'symlink-manager'

    # create groups
    groupsContainer = document.createElement 'div'
    groupsContainer.classList.add 'groups'
    @element.appendChild groupsContainer

    for key of groups
      groupView = new GroupView key
      groupsContainer.appendChild do groupView.getElement

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
