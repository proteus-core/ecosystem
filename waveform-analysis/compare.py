#!/usr/bin/env python3

import pywellen
from types import SimpleNamespace
import re
import sys
import inspect


class NestedNamespace(SimpleNamespace):
  def __init__(self, dictionary, **kwargs):
    super().__init__(**kwargs)

    for key, value in dictionary.items():
      if isinstance(value, dict):
        self.__setattr__(key, NestedNamespace(value))
      else:
        self.__setattr__(key, value)


class ProteusWaveform:
  def __init__(self, vcdname, signals=[]):
    self.waveform = pywellen.Waveform(vcdname)
        
    self.TOP = self.build_signal_namespace().TOP
    self.PL  = self.TOP.Core.pipeline
    self.ID  = self.TOP.Core.pipeline.decode
    try:
      self.WB = self.TOP.Core.pipeline.writeback
      self.is_static = True
    except:
      self.WB = self.TOP.Core.pipeline.retirementStage
      self.is_static = False
    self.RF  = self.TOP.Core.pipeline.RegisterFileAccessor
    self.CSR = self.TOP.Core.pipeline.CsrFile

  def build_signal_namespace(self, scope = None):
    hier = self.waveform.hierarchy
    scopes = scope.scopes(hier) if scope is not None else hier.top_scopes()

    d = {}
    if scope:
      vars = scope.vars(hier)

      for var in vars:
        d[var.name(hier)] = var

    for scope in scopes:
      d[scope.name(hier)] = self.build_signal_namespace(scope)
    
    return NestedNamespace(d)

  def get_sequence(self):
    seq = []

    for t, v in [(t, v) for (t, v) in self.signal(self.PL.clk).all_changes()]:
      print(v)
      try:
        v = int(v, 2)
      except:
        continue
      
      if v == 1:
        is_done = self.as_int(self.WB.arbitration_isDone, t) == 1
        if is_done:
          pc = self.as_int(self.WB.in_PC, t)
          value = self.as_int(self.WB.in_RD_DATA, t)
          reg = self.as_int(self.WB.in_RD_TYPE, t)
          if not self.is_static:
            addr = self.as_int(self.WB.in_LSU_TARGET_ADDRESS, t)
            rs2 = self.as_int(self.WB.in_RS2_DATA, t)
          else:
            addr = 0
            rs2 = 0
          rs1 = self.as_int(self.WB.in_RS1_DATA, t)
          # mmac = self.as_int(self.WB.value_MMAC, t)
          seq.append((pc, value, reg, addr, rs1, rs2, t))

    return seq

  def signal(self, name):
    return self.waveform.get_signal(name)

  def as_int(self, signal, time):
    return int(self.signal(signal).value_at_time(time), 2)



zero = ProteusWaveform(sys.argv[1])
good = ProteusWaveform(sys.argv[2])

zero_s = zero.get_sequence()
good_s = good.get_sequence()

for (idx, (pc, val, reg, addr, rs1, rs2, t)) in enumerate(zero_s):
  (pc64, val64, reg64, addr64, rs164, rs264, t64) = good_s[idx]
  if pc != pc64 or val != val64 or reg != reg64 or rs2 != rs264 or rs1 != rs164:
    print("PC:", pc, pc64)
    print("RD_VALUE:", val, val64)
    print("RD_TYPE:", reg, reg64)
    print("LSU_ADDR:", addr, addr64)
    print("RS1_DATA:", rs1, rs164)
    print("RS2_DATA:", rs2, rs264)
    print("timestamp:", t, t64)
    print(idx)
    break
