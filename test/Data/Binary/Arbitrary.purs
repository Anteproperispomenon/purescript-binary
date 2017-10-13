module Data.Binary.Arbitraty where

import Prelude
import Data.Binary (Bit(..), Byte(..), Nibble(..))
import Data.Newtype (class Newtype)
import Test.QuickCheck (class Arbitrary, arbitrary)

newtype ArbBit = ArbBit Bit
derive newtype instance eqArbBit :: Eq ArbBit
derive newtype instance showArbBit :: Show ArbBit
instance arbitraryBit :: Arbitrary ArbBit where
  arbitrary = ArbBit <<< Bit <$> arbitrary

newtype ArbNibble = ArbNibble Nibble
derive instance newtypeArbNibble :: Newtype ArbNibble _
derive newtype instance eqArbNibble :: Eq ArbNibble
derive newtype instance showArbNibble :: Show ArbNibble

instance arbitraryNibble :: Arbitrary ArbNibble where
  arbitrary = do
   (ArbBit a) <- arbitrary
   (ArbBit b) <- arbitrary
   (ArbBit c) <- arbitrary
   (ArbBit d) <- arbitrary
   pure $ ArbNibble $ Nibble a b c d

newtype ArbByte = ArbByte Byte
derive instance newtypeArbByte :: Newtype ArbByte _
derive newtype instance eqArbByte :: Eq ArbByte
derive newtype instance showArbByte :: Show ArbByte

instance arbitraryByte :: Arbitrary ArbByte where
  arbitrary = do
    (ArbNibble n1) <- arbitrary
    (ArbNibble n2) <- arbitrary
    pure $ ArbByte $ Byte n1 n2