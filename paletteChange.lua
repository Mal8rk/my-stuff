local paletteChange = {}


local cachedStuff = {}

function paletteChange.getShaderAndUniforms(paletteIndex,imageName,colourSimilarityThreshold)
    if paletteIndex <= 0 then
        return nil,nil
    end


    if cachedStuff[imageName] == nil then
        local imagePath = Misc.resolveGraphicsFile(imageName) or (io.exists(imageName) and imageName) or nil

        if imagePath ~= nil then
            local image = Graphics.loadImage(imagePath)

            local shaderObj = Shader()
            shaderObj:compileFromFile(nil, Misc.resolveFile("paletteChange.frag"), {COLOUR_COUNT = image.width})


            cachedStuff[imageName] = {shaderObj, image}
        else
            cachedStuff[imageName] = 0 -- 0 means no shader
        end
    end
    

    local theStuff = cachedStuff[imageName]


    if theStuff == 0 then
        return nil,nil
    end


    local shaderObj = theStuff[1]
    local uniforms = {
        paletteImage = theStuff[2],
        currentPaletteY = ((paletteIndex + 0.1) / theStuff[2].height),
        colourSimilarityThreshold = colourSimilarityThreshold or 0.001,
        tintColor = Color(1,1,1,1),
    }


    return shaderObj,uniforms
end


return paletteChange