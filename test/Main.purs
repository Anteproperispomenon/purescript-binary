module Test.Main where

import Prelude

import Data.Binary.Bits.Spec as Bits
import Data.Binary.UnsignedInt.Spec as UnsignedInt
import Data.Binary.SignedInt.Spec as SignedInt
import Effect (Effect)
import Test.Unit.Main (runTest)

main :: Effect Unit
main = runTest do
  Bits.spec
  UnsignedInt.spec
  SignedInt.spec
