main();

function main() {
    //canvas that the models will be drawn onto
    const canvas = document.querySelector("#glcanvas");

    //webGL's services to be used for rendering
    const gl = canvas.getContext("webgl");

    //vertex shader, lighting is yet to be added; will be done in future update
    const vsSource =
	  attribute vec4 aVertexPosition;
          uniform mat4 uModelViewMatrix;
          uniform mat4 uProjectionMatrix;
          void main() {
	      gl_Position = uProjectionMatrix * uModelViewMatrix * aVertexPosition;
          };

    //fragment shader, works with vertex shader to complete a full render of the page
    const fsSource =
	  void main() {
	      gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
	  };

    

    //checking that webGL exists
    if (gl == null) {

	alert(
	    "Error",
	);
	return;
    }

    gl.clearColor(0,0,0,1.0);
    gl.clear(gl.COLOR_BUFFER_BIT);
}
