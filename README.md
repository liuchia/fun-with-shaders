### Fractals, Raytracing, Raymarching and some other experiments with shaders.

#### Mandelbrot, Julia 
![](https://github.com/liuchia/Fractals-Raytracing-etc/blob/master/Gallery/Mandelbrot.png?raw=true)

Simple iteration count rendering of Mandelbrot set.

![](https://github.com/liuchia/Fractals-Raytracing-etc/blob/master/Gallery/Julia.png?raw=true)

And one for the Julia set.

#### Orbit Traps, Bitmap Traps
![](https://github.com/liuchia/Fractals-Raytracing-etc/blob/master/Gallery/Orbit_Trap.png?raw=true)

Another popular way to render fractals is to use orbit traps. The simple iteration count method colours a location based on how long it takes to escape a certain radius. With an orbit trap, colouring is based on when in a pixel's path it enters some geometric object : In the above case it was a ring, coloured based of iteration count modulo 4.

![](https://github.com/liuchia/Fractals-Raytracing-etc/blob/master/Gallery/Bitmap_Trap.png?raw=true)

A similar concept is the bitmap trap, where an image is used in place of the geometric object. [Inigo Quilez](http://www.iquilezles.org/www/index.htm) has some pretty good articles.

![](https://github.com/liuchia/Fractals-Raytracing-etc/blob/master/Gallery/Bitmap_Trap_2.png?raw=true)

#### Raytracing
![](https://github.com/liuchia/Fractals-Raytracing-etc/blob/master/Gallery/Raytracer.png?raw=true)

Raytracing is the process of firing rays from the camera until it hits a surface to determine how to colour each pixel. Above calculated Sphere-Ray and Sphere-Plane intersections and used Phong lighting with reflections.

![](https://github.com/liuchia/Fractals-Raytracing-etc/blob/master/Gallery/Raytracer_2.png?raw=true)

Rearranged the spheres and increased maximum reflection depth.

#### Raymarching
![](https://github.com/liuchia/Fractals-Raytracing-etc/blob/master/Gallery/Raymarching.png?raw=true)

Raymarching incrementally moves a ray until some condition is met, for example being under the height of the terrain in the above. From that, an approximate intersection position can be found. The normal is approximated with a finite difference method.

![](https://github.com/liuchia/Fractals-Raytracing-etc/blob/master/Gallery/Raymarching_2.png?raw=true)

Different terrain colouring and simplex noise.