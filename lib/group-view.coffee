fs = require 'fs-plus'
{exec} = require 'child_process'

module.exports =
class GroupView
  constructor: (groupName) ->
    # set default configuration
    if (!atom.config.get('symlink-manager'))
      atom.config.set('symlink-manager', this.config)

    # variables
    @groupName = groupName
    @group = atom.config.get 'symlink-manager.groups.' + groupName
    @defaults = atom.config.get 'symlink-manager.defaults'
    folders = @group.folders

    # Create panel
    @element = document.createElement 'atom-panel'
    @element.classList.add 'group', 'top'
    padded = document.createElement 'div'
    padded.classList.add 'padded'
    padded.textContent = @group.description
    linkAll = document.createElement 'span'
    linkAll.classList.add 'inline-block', 'text-highlight', 'pull-right', 'pointer'
    linkAll.textContent = 'Link'
    linkAll.onclick = @all.bind @, true
    padded.appendChild linkAll
    unlinkAll = document.createElement 'span'
    unlinkAll.classList.add 'inline-block', 'text-highlight', 'pull-right', 'pointer'
    unlinkAll.textContent = 'Unlink'
    unlinkAll.onclick = @all.bind @, false
    padded.appendChild unlinkAll

    @element.appendChild padded

    # create list
    listContainer = document.createElement 'div'
    listContainer.classList.add 'select-list'
    padded.appendChild listContainer
    list = document.createElement 'ol'
    list.classList.add 'list-group', 'mark-active'
    listContainer.appendChild list
    @list = list

    for key, value of folders
      @renderItem key, value

  renderItem: (folderName, folderOptions) ->
    self = @
    src = @group.src || @defaults.src
    dst = @group.dst || @defaults.dst
    srcPath = [src, folderName].join '/'
    dstPath = [dst, folderName].join '/'
    list = @list
    fs.isDirectory srcPath, (existsDir) ->
      if !existsDir
        return
      fs.isSymbolicLink dstPath, (exists) ->
        item = document.createElement('li')
        if exists
          item.classList.add 'active', 'selected'
        item.classList.add 'folder', 'folder-' + folderName, 'group-' +
        item.textContent = folderName
        item.onclick = self.onClickItem.bind self, srcPath, dstPath, item
        if folderOptions.url
          button = document.createElement 'span'
          button.classList.add 'inline-block', 'text-highlight', 'pull-right', 'pointer'
          button.textContent = 'repo'
          button.onclick = self.openPath.bind self, folderOptions.url
          item.appendChild button;

        list.appendChild item


  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  onClickItem: (srcPath, dstPath, item, e) ->
    @preventDefault e
    fs.isSymbolicLink dstPath, (exists) ->
      if exists
        fs.unlink dstPath, ->
          item.classList.remove 'active', 'selected'
      else
        fs.symlink srcPath + '/', dstPath, 'dir', ->
          item.classList.add 'active', 'selected'

  openPath: (path, e) ->
    @preventDefault e
    process_architecture = process.platform
    switch process_architecture
      when 'darwin' then exec ('open "'+path+'"')
      when 'linux' then exec ('xdg-open "'+path+'"')
      when 'win32' then Shell.openExternal(path)

  all: (link) ->
    self = @
    src = @group.src || @defaults.src
    dst = @group.dst || @defaults.dst
    els = @list.querySelectorAll('.folder')
    i = 0
    operator = if link then 'add' else 'remove'

    while i < els.length
      els[i].classList[operator] 'active', 'selected'
      i++

    for key of @group.folders
      do ->
        srcPath = [src, key].join '/'
        dstPath = [dst, key].join '/'
        fs.exists srcPath, (existsSrc) ->
          if !existsSrc
            return
          fs.isSymbolicLink dstPath, (exists) ->
            if !link && exists
              fs.unlink dstPath, ->
            if link && !exists
              fs.symlink srcPath + '/', dstPath, 'dir', ->

  preventDefault: (e) ->
    do e.preventDefault
    do e.stopPropagation
