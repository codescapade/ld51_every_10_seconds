
let project = new Project('Be Fast');

project.addAssets('assets/**', {
  nameBaseDir: 'assets',
  destination: '{dir}/{name}',
  name: '{dir}/{name}'
});

project.icon = 'icon.png';

project.addShaders('shaders/**');

project.addSources('source');


project.addLibrary('aeons');
project.addLibrary('ldtk-haxe-api');
project.addLibrary('deepnightLibs');

project.addDefine('use_ldtk');

project.addParameter('-dce full');

project.targetOptions.html5.disableContextMenu = true;
project.windowOptions.width = 960;
project.windowOptions.height = 540;


resolve(project);