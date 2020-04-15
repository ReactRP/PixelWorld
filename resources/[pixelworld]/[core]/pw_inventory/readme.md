# Mythic Inventory
Inventory system for Mythic RP, this is the original version that DiscworldZA's disc-inventoryhud is created based off. This had originally been esx_inventoryhud but has since gone through a complete back-end rewrite to work with my custom framework as well as an amost entire rewrite of the front-end to be more inline with what I am wanting for my inventory.

The original pull of the esx_inventoryhud was made prior to the author pulling his release, and it was 

__NOTE: This is the Mythic Framework dependant version, if you're wanting the ESX version check out [this](https://github.com/DiscworldZA/gta-resources/tree/master/disc-inventoryhud)__

## Compiling CSS
This will just require you to have any sort of ability to compile SASS into a CSS stylesheet. I personally use the [Live SASS Compiler](https://marketplace.visualstudio.com/items?itemName=ritwickdey.live-sass) extension for Visual Studio Code. But again, any SASS compiler will work to compile the source of my custom styling for the inventory. And below are the settings I use to get it to build correctly in the right location:

```json
"liveSassCompile.settings.formats":[{
        "format": "compressed",
        "extensionName": ".min.css",
        "savePath": "~/../"
    },
],
```