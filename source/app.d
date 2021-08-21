import gameapp;

void main()
{
    GameAppConfig appConfig;
    appConfig.width = 640;
    appConfig.height = 480;
    appConfig.title = "ninjaemon";

    GameApp app;

    runGameApp(app, appConfig);
}
