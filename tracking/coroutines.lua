require 'inline'

-- some coroutines
local c = {}

-- some defines
inline.preamble [[
      #define max(a,b)  ((a)>(b) ? (a) : (b))
      #define abs(a)    (a) < 0 ? -(a) : (a)
      #define square(a) (a)*(a)
]]

-- match a prototype against a prediction field

c.RBF = inline.load [[
      //-- get args
      const void* torch_Tensor_id = luaT_checktypename2id(L, "torch.FloatTensor");
      THFloatTensor *input_data    = luaT_checkudata(L, 1, torch_Tensor_id);
      THFloatTensor *output_data   = luaT_checkudata(L, 2, torch_Tensor_id);
      THFloatTensor *code_data     = luaT_checkudata(L, 3, torch_Tensor_id);
      THFloatTensor *weight_data   = luaT_checkudata(L, 4, torch_Tensor_id);
      THFloatTensor *std_data      = luaT_checkudata(L, 5, torch_Tensor_id);
      
      int i,k,x,y;
      int ichannels = input_data->size[0];
      int iheight = input_data->size[1];
      int iwidth = input_data->size[2];
      int numProto = weight_data->size[0];
      float *input = THFloatTensor_data(input_data);
      float *output = THFloatTensor_data(output_data);
      float *code = THFloatTensor_data(code_data);
      float *weight = THFloatTensor_data(weight_data);
      float *std = THFloatTensor_data(std_data);
      float dist, yi_hat, sigma;

      for (y=0; y<iheight; y++) {
         for (x=0; x<iwidth; x++) {
            yi_hat = 0;
            for (i=0; i<numProto; i++) {
               dist = 0;
               sigma = max(0.00001, std[i]);
               for (k=0; k<ichannels; k++)	dist += square(input[(y+k*iheight)*iwidth+x] - code[k+i*ichannels]);
               yi_hat += weight[i]*exp(-dist/(2*sigma*sigma));
//             printf("dist: %%f, std: %%f, weight: %%f, yi_hat: %%f\n", dist, std[i], weight[i], yi_hat);
            }
            output[y*iwidth+x] = yi_hat;
         }
      }
      return 1;
]]

-- return package
return c
