return {
  version = "1.2",
  luaversion = "5.1",
  tiledversion = "1.3.5",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 10,
  height = 10,
  tilewidth = 16,
  tileheight = 16,
  nextlayerid = 3,
  nextobjectid = 1,
  properties = {},
  tilesets = {
    {
      name = "1",
      firstgid = 1,
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 32,
      image = "../../image/terrain/1.png",
      imagewidth = 512,
      imageheight = 384,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      terrains = {},
      tilecount = 768,
      tiles = {}
    },
    {
      name = "3",
      firstgid = 769,
      tilewidth = 16,
      tileheight = 16,
      spacing = 0,
      margin = 0,
      columns = 32,
      image = "../../image/terrain/3.png",
      imagewidth = 512,
      imageheight = 384,
      tileoffset = {
        x = 0,
        y = 0
      },
      grid = {
        orientation = "orthogonal",
        width = 16,
        height = 16
      },
      properties = {},
      terrains = {},
      tilecount = 768,
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      id = 1,
      name = "layer1",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        65, 66, 67, 68, 833, 834, 833, 834, 835, 836,
        97, 98, 833, 834, 835, 836, 865, 866, 867, 868,
        129, 130, 865, 866, 867, 868, 897, 898, 899, 900,
        161, 162, 897, 898, 899, 900, 929, 930, 931, 932,
        0, 0, 929, 930, 931, 932, 67, 68, 0, 0,
        0, 0, 0, 0, 97, 98, 99, 100, 0, 0,
        0, 0, 0, 0, 129, 130, 131, 132, 0, 0,
        0, 0, 0, 0, 161, 162, 163, 164, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "tilelayer",
      id = 2,
      name = "layer2",
      x = 0,
      y = 0,
      width = 10,
      height = 10,
      visible = false,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        461, 462, 0, 0, 1224, 0, 0, 0, 0, 0,
        461, 462, 0, 1224, 0, 0, 0, 1224, 0, 0,
        493, 494, 0, 1224, 0, 0, 0, 0, 0, 0,
        461, 462, 1224, 0, 1224, 0, 0, 0, 0, 0,
        493, 494, 1224, 0, 0, 0, 0, 461, 462, 0,
        0, 0, 0, 0, 0, 0, 0, 493, 494, 0
      }
    }
  }
}
