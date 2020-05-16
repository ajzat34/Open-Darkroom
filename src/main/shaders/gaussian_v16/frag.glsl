# version 300 es
  // generated by OpenDarkroom/tools/nlmeans
  // impliments fast nlmeans filter in glsl
  uniform sampler2D texSampler;
  uniform ivec2 size;
  uniform sampler2D weights;
  in highp vec2 textureCoord;
  out highp vec4 fragmentColor;
  void main(void){
 highp ivec2 p = ivec2(int(textureCoord.x * float(size.x)), int(textureCoord.y * float(size.y)));
 highp vec3 acc = vec3(0.0);
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-16, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(4,0), 0).r;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-15, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(3,0), 0).a;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-14, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(3,0), 0).b;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-13, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(3,0), 0).g;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-12, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(3,0), 0).r;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-11, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(2,0), 0).a;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-10, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(2,0), 0).b;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-9, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(2,0), 0).g;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-8, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(2,0), 0).r;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-7, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(1,0), 0).a;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-6, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(1,0), 0).b;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-5, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(1,0), 0).g;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-4, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(1,0), 0).r;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-3, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(0,0), 0).a;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-2, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(0,0), 0).b;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+-1, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(0,0), 0).g;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+0, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(0,0), 0).r;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+1, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(0,0), 0).g;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+2, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(0,0), 0).b;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+3, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(0,0), 0).a;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+4, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(1,0), 0).r;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+5, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(1,0), 0).g;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+6, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(1,0), 0).b;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+7, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(1,0), 0).a;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+8, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(2,0), 0).r;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+9, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(2,0), 0).g;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+10, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(2,0), 0).b;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+11, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(2,0), 0).a;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+12, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(3,0), 0).r;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+13, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(3,0), 0).g;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+14, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(3,0), 0).b;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+15, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(3,0), 0).a;
 acc+= texelFetch(texSampler, ivec2(clamp(p.x, 0, size.x-1), clamp(p.y+16, 0, size.y-1)), 0).rgb * texelFetch(weights, ivec2(4,0), 0).r;

  fragmentColor.rgb = acc;
  fragmentColor.a  = 1.0;}
