require 'nn'

local Dropout, Parent = torch.class('nn.Dropout', 'nn.Module')

function Dropout:__init(p)
   Parent.__init(self)
   self.p = p or 0.5
   self.train = true
   if self.p >= 1 or self.p < 0 then
      error('<Dropout> illegal percentage, must be 0 <= p < 1')
   end
   self.noise = torch.Tensor()
end

function Dropout:updateOutput(input)
   self.noise:resizeAs(input)
   self.output:resizeAs(input):copy(input)
   if self.train then
      self.noise:bernoulli(1-self.p)
      self.output:cmul(self.noise)
   else
      self.output:mul(1-self.p)
   end
   return self.output
end

function Dropout:updateGradInput(input, gradOutput)
   if self.train then
      self.gradInput:resizeAs(gradOutput):copy(gradOutput)
      self.gradInput:cmul(self.noise) -- simply mask the gradients with the noise vector
   else
      error('backprop only defined while training')
   end
   return self.gradInput
end

