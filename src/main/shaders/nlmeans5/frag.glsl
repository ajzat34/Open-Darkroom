# version 300 es
  // generated by OpenDarkroom/tools/nlmeans
  // impliments fast nlmeans filter in glsl
  uniform sampler2D texSampler;
  uniform highp float amount;
  uniform ivec2 size;
  uniform bool vnoise;
  uniform bool vweights;
  uniform int selweight;
  uniform highp float mag;
  in highp vec2 textureCoord;
  out highp vec4 fragmentColor;
  const highp vec3 dotsums = vec3(0.33333333333,0.33333333333,0.33333333333);
  highp vec4 csample(ivec2 s) {return texelFetch(texSampler, ivec2(clamp(s.x, 0, size.x-1), clamp(s.y, 0, size.y-1)), 0);}
  highp vec3 rgbsample(ivec2 s) {return texelFetch(texSampler, ivec2(clamp(s.x, 0, size.x-1), clamp(s.y, 0, size.y-1)), 0).rgb;}
  void sampleKernal(ivec2 center, inout vec3 [9]src){
 src[0] = rgbsample(center+ivec2(-1,1));
 src[1] = rgbsample(center+ivec2(0,1));
 src[2] = rgbsample(center+ivec2(1,1));
 src[3] = rgbsample(center+ivec2(-1,0));
 src[4] = rgbsample(center+ivec2(0,0));
 src[5] = rgbsample(center+ivec2(1,0));
 src[6] = rgbsample(center+ivec2(-1,-1));
 src[7] = rgbsample(center+ivec2(0,-1));
 src[8] = rgbsample(center+ivec2(1,-1));
}
highp float placeAndCompare(ivec2 center, vec3 [9]compare, inout vec3 insample){
  highp float acc = 0.001;
  highp vec3 diff;
  ( diff = rgbsample(center+ivec2(-1,1)) -compare[0]);
  acc += dot(diff*diff, dotsums);
  ( diff = rgbsample(center+ivec2(0,1)) -compare[1]);
  acc += dot(diff*diff, dotsums);
  ( diff = rgbsample(center+ivec2(1,1)) -compare[2]);
  acc += dot(diff*diff, dotsums);
  ( diff = rgbsample(center+ivec2(-1,0)) -compare[3]);
  acc += dot(diff*diff, dotsums);
  ( diff = rgbsample(center+ivec2(0,0)) -compare[4]);
  acc += dot(diff*diff, dotsums);
  ( diff = rgbsample(center+ivec2(1,0)) -compare[5]);
  acc += dot(diff*diff, dotsums);
  ( diff = rgbsample(center+ivec2(-1,-1)) -compare[6]);
  acc += dot(diff*diff, dotsums);
  ( diff = rgbsample(center+ivec2(0,-1)) -compare[7]);
  acc += dot(diff*diff, dotsums);
  ( diff = rgbsample(center+ivec2(1,-1)) -compare[8]);
  acc += dot(diff*diff, dotsums);
  insample = rgbsample(center);
  return acc/9.0;
}
void main(void){

    highp ivec2 p = ivec2(int(textureCoord.x * float(size.x)), int(textureCoord.y * float(size.y)));
    highp vec4 color = csample(p);
    highp float [25]finalKernalWeights;
    highp vec3 [25]finalKernalSamples;
    highp vec3 [9]center;

    sampleKernal(p+ivec2( 0, 0), center);
   finalKernalWeights[0] = placeAndCompare(p+ivec2(-2, 2), center, finalKernalSamples[0]);
 finalKernalWeights[1] = placeAndCompare(p+ivec2(-1, 2), center, finalKernalSamples[1]);
 finalKernalWeights[2] = placeAndCompare(p+ivec2(0, 2), center, finalKernalSamples[2]);
 finalKernalWeights[3] = placeAndCompare(p+ivec2(1, 2), center, finalKernalSamples[3]);
 finalKernalWeights[4] = placeAndCompare(p+ivec2(2, 2), center, finalKernalSamples[4]);
 finalKernalWeights[5] = placeAndCompare(p+ivec2(-2, 1), center, finalKernalSamples[5]);
 finalKernalWeights[6] = placeAndCompare(p+ivec2(-1, 1), center, finalKernalSamples[6]);
 finalKernalWeights[7] = placeAndCompare(p+ivec2(0, 1), center, finalKernalSamples[7]);
 finalKernalWeights[8] = placeAndCompare(p+ivec2(1, 1), center, finalKernalSamples[8]);
 finalKernalWeights[9] = placeAndCompare(p+ivec2(2, 1), center, finalKernalSamples[9]);
 finalKernalWeights[10] = placeAndCompare(p+ivec2(-2, 0), center, finalKernalSamples[10]);
 finalKernalWeights[11] = placeAndCompare(p+ivec2(-1, 0), center, finalKernalSamples[11]);
 finalKernalWeights[12] = 0.01;
 finalKernalSamples[12] = color.rgb;
 finalKernalWeights[13] = placeAndCompare(p+ivec2(1, 0), center, finalKernalSamples[13]);
 finalKernalWeights[14] = placeAndCompare(p+ivec2(2, 0), center, finalKernalSamples[14]);
 finalKernalWeights[15] = placeAndCompare(p+ivec2(-2, -1), center, finalKernalSamples[15]);
 finalKernalWeights[16] = placeAndCompare(p+ivec2(-1, -1), center, finalKernalSamples[16]);
 finalKernalWeights[17] = placeAndCompare(p+ivec2(0, -1), center, finalKernalSamples[17]);
 finalKernalWeights[18] = placeAndCompare(p+ivec2(1, -1), center, finalKernalSamples[18]);
 finalKernalWeights[19] = placeAndCompare(p+ivec2(2, -1), center, finalKernalSamples[19]);
 finalKernalWeights[20] = placeAndCompare(p+ivec2(-2, -2), center, finalKernalSamples[20]);
 finalKernalWeights[21] = placeAndCompare(p+ivec2(-1, -2), center, finalKernalSamples[21]);
 finalKernalWeights[22] = placeAndCompare(p+ivec2(0, -2), center, finalKernalSamples[22]);
 finalKernalWeights[23] = placeAndCompare(p+ivec2(1, -2), center, finalKernalSamples[23]);
 finalKernalWeights[24] = placeAndCompare(p+ivec2(2, -2), center, finalKernalSamples[24]);
 highp float maxweight = 0.0;
 if (finalKernalWeights[0] > maxweight) {maxweight = finalKernalWeights[0];}
 if (finalKernalWeights[1] > maxweight) {maxweight = finalKernalWeights[1];}
 if (finalKernalWeights[2] > maxweight) {maxweight = finalKernalWeights[2];}
 if (finalKernalWeights[3] > maxweight) {maxweight = finalKernalWeights[3];}
 if (finalKernalWeights[4] > maxweight) {maxweight = finalKernalWeights[4];}
 if (finalKernalWeights[5] > maxweight) {maxweight = finalKernalWeights[5];}
 if (finalKernalWeights[6] > maxweight) {maxweight = finalKernalWeights[6];}
 if (finalKernalWeights[7] > maxweight) {maxweight = finalKernalWeights[7];}
 if (finalKernalWeights[8] > maxweight) {maxweight = finalKernalWeights[8];}
 if (finalKernalWeights[9] > maxweight) {maxweight = finalKernalWeights[9];}
 if (finalKernalWeights[10] > maxweight) {maxweight = finalKernalWeights[10];}
 if (finalKernalWeights[11] > maxweight) {maxweight = finalKernalWeights[11];}
 if (finalKernalWeights[12] > maxweight) {maxweight = finalKernalWeights[12];}
 if (finalKernalWeights[13] > maxweight) {maxweight = finalKernalWeights[13];}
 if (finalKernalWeights[14] > maxweight) {maxweight = finalKernalWeights[14];}
 if (finalKernalWeights[15] > maxweight) {maxweight = finalKernalWeights[15];}
 if (finalKernalWeights[16] > maxweight) {maxweight = finalKernalWeights[16];}
 if (finalKernalWeights[17] > maxweight) {maxweight = finalKernalWeights[17];}
 if (finalKernalWeights[18] > maxweight) {maxweight = finalKernalWeights[18];}
 if (finalKernalWeights[19] > maxweight) {maxweight = finalKernalWeights[19];}
 if (finalKernalWeights[20] > maxweight) {maxweight = finalKernalWeights[20];}
 if (finalKernalWeights[21] > maxweight) {maxweight = finalKernalWeights[21];}
 if (finalKernalWeights[22] > maxweight) {maxweight = finalKernalWeights[22];}
 if (finalKernalWeights[23] > maxweight) {maxweight = finalKernalWeights[23];}
 if (finalKernalWeights[24] > maxweight) {maxweight = finalKernalWeights[24];}
 finalKernalWeights[0] = maxweight-finalKernalWeights[0];
 finalKernalWeights[1] = maxweight-finalKernalWeights[1];
 finalKernalWeights[2] = maxweight-finalKernalWeights[2];
 finalKernalWeights[3] = maxweight-finalKernalWeights[3];
 finalKernalWeights[4] = maxweight-finalKernalWeights[4];
 finalKernalWeights[5] = maxweight-finalKernalWeights[5];
 finalKernalWeights[6] = maxweight-finalKernalWeights[6];
 finalKernalWeights[7] = maxweight-finalKernalWeights[7];
 finalKernalWeights[8] = maxweight-finalKernalWeights[8];
 finalKernalWeights[9] = maxweight-finalKernalWeights[9];
 finalKernalWeights[10] = maxweight-finalKernalWeights[10];
 finalKernalWeights[11] = maxweight-finalKernalWeights[11];
 finalKernalWeights[12] = maxweight-finalKernalWeights[12];
 finalKernalWeights[13] = maxweight-finalKernalWeights[13];
 finalKernalWeights[14] = maxweight-finalKernalWeights[14];
 finalKernalWeights[15] = maxweight-finalKernalWeights[15];
 finalKernalWeights[16] = maxweight-finalKernalWeights[16];
 finalKernalWeights[17] = maxweight-finalKernalWeights[17];
 finalKernalWeights[18] = maxweight-finalKernalWeights[18];
 finalKernalWeights[19] = maxweight-finalKernalWeights[19];
 finalKernalWeights[20] = maxweight-finalKernalWeights[20];
 finalKernalWeights[21] = maxweight-finalKernalWeights[21];
 finalKernalWeights[22] = maxweight-finalKernalWeights[22];
 finalKernalWeights[23] = maxweight-finalKernalWeights[23];
 finalKernalWeights[24] = maxweight-finalKernalWeights[24];
 highp float weightsum = finalKernalWeights[0]+finalKernalWeights[1]+finalKernalWeights[2]+finalKernalWeights[3]+finalKernalWeights[4]+finalKernalWeights[5]+finalKernalWeights[6]+finalKernalWeights[7]+finalKernalWeights[8]+finalKernalWeights[9]+finalKernalWeights[10]+finalKernalWeights[11]+finalKernalWeights[12]+finalKernalWeights[13]+finalKernalWeights[14]+finalKernalWeights[15]+finalKernalWeights[16]+finalKernalWeights[17]+finalKernalWeights[18]+finalKernalWeights[19]+finalKernalWeights[20]+finalKernalWeights[21]+finalKernalWeights[22]+finalKernalWeights[23]+finalKernalWeights[24];
 highp vec3 acc = vec3(0);
 acc += (finalKernalWeights[0]/weightsum)*finalKernalSamples[0];
 acc += (finalKernalWeights[1]/weightsum)*finalKernalSamples[1];
 acc += (finalKernalWeights[2]/weightsum)*finalKernalSamples[2];
 acc += (finalKernalWeights[3]/weightsum)*finalKernalSamples[3];
 acc += (finalKernalWeights[4]/weightsum)*finalKernalSamples[4];
 acc += (finalKernalWeights[5]/weightsum)*finalKernalSamples[5];
 acc += (finalKernalWeights[6]/weightsum)*finalKernalSamples[6];
 acc += (finalKernalWeights[7]/weightsum)*finalKernalSamples[7];
 acc += (finalKernalWeights[8]/weightsum)*finalKernalSamples[8];
 acc += (finalKernalWeights[9]/weightsum)*finalKernalSamples[9];
 acc += (finalKernalWeights[10]/weightsum)*finalKernalSamples[10];
 acc += (finalKernalWeights[11]/weightsum)*finalKernalSamples[11];
 acc += (finalKernalWeights[12]/weightsum)*finalKernalSamples[12];
 acc += (finalKernalWeights[13]/weightsum)*finalKernalSamples[13];
 acc += (finalKernalWeights[14]/weightsum)*finalKernalSamples[14];
 acc += (finalKernalWeights[15]/weightsum)*finalKernalSamples[15];
 acc += (finalKernalWeights[16]/weightsum)*finalKernalSamples[16];
 acc += (finalKernalWeights[17]/weightsum)*finalKernalSamples[17];
 acc += (finalKernalWeights[18]/weightsum)*finalKernalSamples[18];
 acc += (finalKernalWeights[19]/weightsum)*finalKernalSamples[19];
 acc += (finalKernalWeights[20]/weightsum)*finalKernalSamples[20];
 acc += (finalKernalWeights[21]/weightsum)*finalKernalSamples[21];
 acc += (finalKernalWeights[22]/weightsum)*finalKernalSamples[22];
 acc += (finalKernalWeights[23]/weightsum)*finalKernalSamples[23];
 acc += (finalKernalWeights[24]/weightsum)*finalKernalSamples[24];

    fragmentColor.rgb = acc;
    fragmentColor.a  = 1.0;
  }
