#include <SDL.h>
#include <SDL_image.h>
#include <string>
#include <vector>

#include <android/log.h>


#include "glad/glad.h"

SDL_Window* window = NULL;

SDL_GLContext maincontext=NULL; // Our opengl context handle

bool gQuit=false;

GLuint gVertexArrayObject=0;
GLuint glVertexBufferObject=0;
GLuint gGraphicsPipelineShaderProgram=0;

const std::vector<GLfloat> vertexPosition{
        -0.8f, -0.8f, 0.0f,
        0.8f, -0.8f, 0.0f,
        0.0f, 0.8f, 0.0
};


struct { // screen size structure
    int w;
    int h;
} screen;

void VertexSpecification();

void CreateGraphicsPipeline();

const std::string gVertexShaderSource =
        "#version 300 es\n"
        "in vec4 position;\n"
        "void main()\n"
        "{\n"
        "   gl_Position = vec4(position);\n"
        "}\n";

const std::string gFragmentShaderSource =
        "#version 300 es\n\n"
        "precision mediump float;\n\n"
        "out vec4 outcolor;\n"
        "void main()\n"
        "{\n"
        "   outcolor = vec4(1.0f, 0.5f, 0.0f, 1.0f);\n"
        "}\n";



GLuint CompileShader(GLuint shaderType, const std::string &shadersource);

void GetOpenGLVersionInfo()
{
    __android_log_print(ANDROID_LOG_INFO,"gl_info","%s", glGetString(GL_VENDOR));
    __android_log_print(ANDROID_LOG_INFO,"gl_info","%s", glGetString(GL_SHADING_LANGUAGE_VERSION));

}

void InitializeProgram()
{
    if(SDL_Init(SDL_INIT_VIDEO)<0)
    {
        __android_log_print(0,"sdl2_native","Failed to initialize SDL");
        exit(1);
    }

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION,3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION,0);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK,SDL_GL_CONTEXT_PROFILE_ES);
    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER,1);

    window = SDL_CreateWindow
            (
                    "Jeu de la vie", SDL_WINDOWPOS_UNDEFINED,
                    SDL_WINDOWPOS_UNDEFINED,
                    640,
                    480,
                    SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL
            );

    maincontext = SDL_GL_CreateContext(window);


    SDL_DisplayMode mode;
    SDL_GetDesktopDisplayMode(0, &mode);
    screen.w = mode.w;
    screen.h = mode.h;

    if(!gladLoadGLES2Loader(SDL_GL_GetProcAddress))
    {
        __android_log_print(0,"sdl2_native","Failed to initialize GLAD");
        exit(1);
    }

    GetOpenGLVersionInfo();


}



void Input()
{
    SDL_Event e;
    while(SDL_PollEvent( &e) != 0)
    {
        if(e.type==SDL_QUIT)
        {
            gQuit=true;
        }
    }
}

void PreDraw()
{
    SDL_GL_MakeCurrent(window, maincontext);
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);

    glViewport(0,0,screen.w,screen.h );
    glClearColor(1.f, 1.f, 0.f,1.f);

    glUseProgram(gGraphicsPipelineShaderProgram);

}

void Draw()
{
    glBindVertexArray(gVertexArrayObject);
    glBindBuffer(GL_ARRAY_BUFFER,glVertexBufferObject);
    glDrawArrays(GL_TRIANGLES,0,3);
}

void SDL_draw_test()
{
    // Setup renderer
    SDL_Renderer* renderer = NULL;
    renderer =  SDL_CreateRenderer( window, -1, SDL_RENDERER_ACCELERATED);


    // Set render color to red ( background will be rendered in this color )
    SDL_SetRenderDrawColor( renderer, 255, 0, 0, 255 );

    // Clear window
    SDL_RenderClear( renderer );
    SDL_RenderPresent(renderer);

    // Creat a rect at pos ( 50, 50 ) that's 50 pixels wide and 50 pixels high.
    SDL_Rect r;
    r.x = 50;
    r.y = 50;
    r.w = 50;
    r.h = 50;

    // Set render color to blue ( rect will be rendered in this color )
    SDL_SetRenderDrawColor( renderer, 0, 0, 255, 255 );

    // Render rect
    SDL_RenderFillRect( renderer, &r );

    // Render the rect to the screen
    SDL_RenderPresent(renderer);

    // Wait for 1 sec
    SDL_Delay( 1000 );

    r.x = 100;
    r.y = 100;
    r.w = 50;
    r.h = 50;

    SDL_RenderFillRect( renderer, &r );
    SDL_RenderPresent(renderer);

    SDL_Delay( 1000 );

    r.x = 200;
    r.y = 200;
    r.w = 50;
    r.h = 50;

    SDL_RenderFillRect( renderer, &r );
    SDL_RenderPresent(renderer);


    SDL_Delay(10);
}



void MainLoop()
{





    while(!gQuit)
    {
        Input();
        PreDraw();
        Draw();
        SDL_GL_SwapWindow(window);
        SDL_Delay(10);
    }

}

void CleanUp()
{
    SDL_DestroyWindow(window);
    SDL_Quit();

}




int main(int /*argc*/, char* /*argv*/[]) {


    InitializeProgram();


    VertexSpecification();

    CreateGraphicsPipeline();

    SDL_draw_test();

    MainLoop();

    CleanUp();

    return EXIT_SUCCESS;
}

GLuint CreateShaderProgram(const std::string& vertexshadersource, const std::string& fragmentshadersource)
{
   GLuint programObject=glCreateProgram();
   GLuint myVertexShader=CompileShader(GL_VERTEX_SHADER,vertexshadersource);

   GLuint myFragmentShader=CompileShader(GL_FRAGMENT_SHADER,fragmentshadersource);
   glAttachShader(programObject,myVertexShader);
   glAttachShader(programObject,myFragmentShader);
   glLinkProgram(programObject);

    const GLsizei maxLength = 1000;
    GLsizei log_length;
    GLchar log[maxLength];

    glGetProgramInfoLog(programObject, maxLength, &log_length, log);
    __android_log_print(ANDROID_LOG_INFO,"gl_program_link","%s",log);

    glValidateProgram(programObject);
    glGetProgramInfoLog(programObject, maxLength, &log_length, log);
    __android_log_print(ANDROID_LOG_INFO,"gl_program_validate","%s",log);


    return(programObject);
}

GLuint CompileShader(GLuint shaderType, const std::string &shadersource) {
    GLuint shaderObject=0;
    if(shaderType==GL_VERTEX_SHADER)
    {
        shaderObject=glCreateShader(GL_VERTEX_SHADER);
    } else if(shaderType == GL_FRAGMENT_SHADER)
    {
        shaderObject=glCreateShader(GL_FRAGMENT_SHADER);
    }
    const char* src = shadersource.c_str();
    glShaderSource(shaderObject, 1,&src,nullptr);
    glCompileShader(shaderObject);
    GLint success = 0;
    glGetShaderiv(shaderObject, GL_COMPILE_STATUS, &success);
    if(success==GL_FALSE)
    {
        __android_log_print(ANDROID_LOG_ERROR,"gl_compilation","Compilation of vertex shader failed");

        GLint logSize = 0;
        glGetShaderiv(shaderObject, GL_INFO_LOG_LENGTH, &logSize);
        // The maxLength includes the NULL character
        std::vector<GLchar> errorLog(logSize);
        glGetShaderInfoLog(shaderObject, logSize, &logSize, &errorLog[0]);
        __android_log_print(ANDROID_LOG_ERROR,"gl_compilation","Error: %s",errorLog.data());
        exit(1);
    }



    return shaderObject;
}

void CreateGraphicsPipeline() {
  gGraphicsPipelineShaderProgram=CreateShaderProgram(gVertexShaderSource,gFragmentShaderSource);
}

void VertexSpecification() {




    glGenVertexArrays(1,&gVertexArrayObject);

    glBindVertexArray(gVertexArrayObject);

    glGenBuffers(1,&glVertexBufferObject);

    glBindBuffer(GL_ARRAY_BUFFER, glVertexBufferObject);

    glBufferData(GL_ARRAY_BUFFER,
                 vertexPosition.size()*sizeof(GLfloat),
                 vertexPosition.data(),
                 GL_STATIC_DRAW);

    glEnableVertexAttribArray(0);

    glVertexAttribPointer(0,3,GL_FLOAT,GL_FALSE,0,(void*)0);
    glBindVertexArray(0);
    glDisableVertexAttribArray(0);


}
