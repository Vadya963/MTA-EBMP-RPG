local hudTextureNames = {
	"ak47icon",
	"baticon",
	"bombicon",
	"BRASSKNUCKLEicon",
	"cameraCrosshair",
	"cameraicon",
	"cellphoneicon",
	"chnsawicon",
	"chromegunicon",
	"colt45icon",
	"cuntgunicon",
	"desert_eagleicon",
	"fire_exicon",
	"fist",
	"flameicon",
	"floweraicon",
	"flowerbicon",
	"font1",
	"font2",
	"golfclubicon",
	"grenadeicon",
	"gun_caneicon",
	"gun_dildo1icon",
	"gun_dildo2icon",
	"gun_paraicon",
	"gun_vibe1icon",
	"gun_vibe2icon",
	"heatseekicon",
	"irgogglesicon",
	"jetpackicon",
	"katanaicon",
	"knifecuricon",
	"M4icon",
	"micro_uziicon",
	"minigunicon",
	"molotovicon",
	"mp5lngicon",
	"nitestickicon",
	"nvgogglesicon",
	"poolcueicon",
	"rocketlaicon",
	"satchelicon",
	"sawnofficon",
	"shotgspaicon",
	"shovelicon",
	"silencedicon",
	"siteM16",
	"siterocket",
	"skateboardIcon",
	"SNIPERcrosshair",
	"SNIPERicon",
	"SPRAYCANicon",
	"teargasicon",
	"tec9icon",
}

local other = {
	"vehiclegrunge256",
}

function replaceTexture(textureName, imgPath)
	local textureReplaceShader = dxCreateShader("client/shaders/texture_replace.fx", 0, 0, false, "world")
	local texture = dxCreateTexture(imgPath .. textureName .. ".png")
	dxSetShaderValue(textureReplaceShader, "gTexture", texture)
	engineApplyShaderToWorldTexture(textureReplaceShader, textureName)
end

function replaceTexture2(textureName, imgPath)
	local textureReplaceShader = dxCreateShader("client/shaders/texture_replace.fx", 150, 0, false, "vehicle")
	local texture = dxCreateTexture(imgPath .. textureName .. ".png")
	dxSetShaderValue(textureReplaceShader, "gTexture", texture)
	engineApplyShaderToWorldTexture(textureReplaceShader, textureName)
end

function replaceTextures()
	for i, textureName in ipairs(hudTextureNames) do
		replaceTexture(textureName, "client/img/hud/")
	end

	for i, textureName in ipairs(other) do
		replaceTexture2(textureName, "client/img/hud/")
	end
end

addEventHandler("onClientResourceStart", resourceRoot, replaceTextures)