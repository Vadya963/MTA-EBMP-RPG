addEventHandler('onClientResourceStart', resourceRoot,
function()
local txd = engineLoadTXD('object.txd',true)
engineImportTXD(txd, 4186)
local dff = engineLoadDFF('object.dff', 0)
engineReplaceModel(dff, 4186)
local col = engineLoadCOL('object.col')
engineReplaceCOL(col, 4186)
engineSetModelLODDistance(4186, 500)





end)

