# You may exclude certain drives (separate with a pipe)
# Example: exclude = 'MyBook' or exclude = 'MyBook|WD Passport'
# Set as something obscure to show all drives (strange, but easier than editing the command)
exclude   = 'NONE'

# Use base 10 numbers, i.e. 1GB = 1000MB. Leave this true to show disk sizes as
# OS X would (since Snow Leopard)
base10       = true

# You may optionally limit the number of disk to show
maxDisks: 10


command: "df -#{if base10 then 'H' else 'h'} | grep '/dev/' | while read -r line; do fs=$(echo $line | awk '{print $1}'); name=$(diskutil info $fs | grep 'Volume Name' | awk '{print substr($0, index($0,$3))}'); echo $(echo $line | awk '{print $2, $3, $4, $5}') $(echo $name | awk '{print substr($0, index($0,$1))}'); done | grep -vE '#{exclude}'"

refreshFrequency: 60000

style: """
  // Change bar height
  bar-height = 6px

  // Align contents left or right
  widget-align = left

  // Position this where you want
  top 240px
  right 250px

  // Statistics text settings
  color #fff
  font-family Helvetica Neue
  background rgba(#000, .5)
  padding 10px 10px 15px
  border-radius 5px

  .container
    width: 300px
    text-align: widget-align
    position: relative
    clear: both

  .disk-container:first-child
    margin-top 8px

  .disk-container
    margin-bottom 20px

  .widget-title
    text-align: widget-align

  .stats-container
    margin-bottom 5px
    border-collapse collapse

  td
    font-size: 14px
    font-weight: 300
    color: rgba(#fff, .9)
    text-shadow: 0 1px 0px rgba(#000, .7)
    text-align: widget-align

  .widget-title
    font-size 10px
    text-transform uppercase
    font-weight bold

  .label
    font-size 8px
    text-transform uppercase
    font-weight bold
    width 50%

  .stat
    width 50%

  .label-disk
    font-size 10px
    text-transform uppercase
    font-weight bold

  .bar-container
    width: 100%
    height: bar-height
    border-radius: bar-height
    float: widget-align
    clear: both
    background: rgba(#fff, .5)
    position: absolute
    margin-bottom: 5px

  .bar
    height: bar-height
    float: widget-align
    transition: width .2s ease-in-out

  .bar:first-child
    if widget-align == left
      border-radius: bar-height 0 0 bar-height
    else
      border-radius: 0 bar-height bar-height 0

  .bar:last-child
    if widget-align == right
      border-radius: bar-height 0 0 bar-height
    else
      border-radius: 0 bar-height bar-height 0

  .bar-inactive
    background: rgba(#0bf, .5)

  .bar-free
    background: rgba(#fc0, .5)

  .bar-used
    background: rgba(#c00, .5)
"""

humanize: (sizeString) ->
  sizeString + 'B'

renderInfo: (total, used, free, pctg, name) -> """
  <div class='disk-container'>
    <div class='label-disk'>#{name} <span class='total'>#{@humanize(total)}</span></div>
      <table class="stats-container" width="100%">
      <tr>
        <td class='stat'>#{@humanize(used)}</td>
        <td class='stat'>#{@humanize(free)}</td>
      </tr>
      <tr>
        <td class="label">used</td>
        <td class="label">free</td>
      </tr>
    </table>
    <div class='bar-container'>
      <div class='bar bar-used' style='width: #{pctg}'></div>
      <div class='bar bar-free' style='width: #{100 - parseInt(pctg)}%'></div>
    </div>
  </div>
"""

render: -> """
  <div class="container">
    <div class="widget-title">Disks</div>
    <div id="disks">
    </div>
  </div>
"""

update: (output, domEl) ->
  disks = output.split('\n')
  $('#disks').html ''

  for disk, i in disks[..(@maxDisks - 1)]
    args = disk.split(' ')
    if (args[4])
      args[4] = args[4..].join(' ')
      $('#disks').append @renderInfo(args...)
