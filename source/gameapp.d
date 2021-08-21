module gameapp;

import std.stdio;
import bindbc.sdl;
import bindbc.opengl;

struct GameAppConfig
{
    uint width;
    uint height;
    string title;
}

struct GameAppState
{
    double dt = 0.0;
}

struct GameApp
{
    void function() onInit = () {};
    void function() onShutdown = () {};
    void function(GameAppState* state) onUpdate = (GameAppState*) {};
}

void runGameApp(GameApp app, GameAppConfig appConfig)
{
    loadSDL();
    assert(isSDLLoaded());

    SDL_Init(SDL_INIT_EVERYTHING);

    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

    auto window = SDL_CreateWindow(appConfig.title.ptr, SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED, appConfig.width, appConfig.height, SDL_WINDOW_OPENGL);
    assert(window);

    auto glctx = SDL_GL_CreateContext(window);
    assert(glctx);
    SDL_GL_MakeCurrent(window, glctx);
    //SDL_GL_SetSwapInterval(1);

    loadOpenGL();
    assert(isOpenGLLoaded());
    writeln(loadedOpenGLVersion());

    app.onInit();

    double fpsCap = 1.0 / 60.0;
    ulong freq = SDL_GetPerformanceFrequency();
    ulong prevTime = SDL_GetPerformanceCounter();

    GameAppState state;

    for (;;)
    {
        ulong nowTime = SDL_GetPerformanceCounter();
        double deltaTime = double(nowTime - prevTime) / freq;
        prevTime = nowTime;

        while (deltaTime < fpsCap)
        {
            uint ms = cast(uint)((fpsCap - deltaTime) * 1000.0);
            SDL_Delay(ms);
            nowTime = SDL_GetPerformanceCounter();
            deltaTime += double(nowTime - prevTime) / freq;
            prevTime = nowTime;
        }

        SDL_Event ev;
        while (SDL_PollEvent(&ev))
        {
            if (ev.type == SDL_QUIT)
                goto app_quit;
        }

        state.dt = deltaTime;
        app.onUpdate(&state);

        SDL_GL_SwapWindow(window);
    }

app_quit:

    app.onShutdown();

    SDL_GL_DeleteContext(glctx);
    SDL_DestroyWindow(window);

    SDL_Quit();
}
