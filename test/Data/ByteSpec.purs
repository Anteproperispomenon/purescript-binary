module Data.Byte.Spec (spec) where

import Control.Monad.Eff.Random (RANDOM)
import Data.Bit (Overflow(..), Bit)
import Data.Bits (add, fromString, leftShift, rightShift, toInt, toString)
import Data.Byte (Byte(..))
import Data.Foldable (all)
import Data.Maybe (Maybe(..))
import Data.Newtype (class Newtype)
import Data.Nibble (Nibble(..))
import Data.String (length, toCharArray)
import Test.QuickCheck (class Arbitrary, Result, (<?>), (===))
import Test.QuickCheck.Arbitrary (arbitrary)
import Test.Unit (TestSuite, suite, test)
import Test.Unit.QuickCheck (quickCheck)
import Data.Nibble.Spec (ArbNibble(ArbNibble))
import Prelude hiding (add)

newtype ArbByte = ArbByte Byte
derive instance newtypeArbByte :: Newtype ArbByte _
derive newtype instance eqArbByte :: Eq ArbByte
derive newtype instance showArbByte :: Show ArbByte

instance arbitraryByte :: Arbitrary ArbByte where
  arbitrary = do
    (ArbNibble n1) <- arbitrary
    (ArbNibble n2) <- arbitrary
    pure $ ArbByte $ Byte n1 n2

spec :: ∀ e. TestSuite (random :: RANDOM | e)
spec = suite "Byte" do
  test "toString has length 8" $ quickCheck propToStringLength
  test "toString contains only 0 and 1" $ quickCheck propHasBinDigits
  test "toString >>> fromString" $ quickCheck propStringRoundtrip
  test "addition works like Int" $ quickCheck propAddition
  test "left shift" $ quickCheck propLeftShift
  test "right shift" $ quickCheck propRightShift

propToStringLength :: ArbByte -> Result
propToStringLength (ArbByte n) = 8 === length (toString n)

propHasBinDigits :: ArbByte -> Result
propHasBinDigits (ArbByte n) = (all (\d -> d == '1' || d == '0') $ toCharArray (toString n))
  <?> "String representation of Byte contains not only digits 1 and 0"

propStringRoundtrip :: ArbByte -> Result
propStringRoundtrip (ArbByte n) = fromString (toString n) === Just n

propAddition :: ArbByte -> ArbByte -> Result
propAddition (ArbByte a) (ArbByte b) =
  case add a b of
    (Overflow true _) -> (toInt a + toInt b) > 15 <?> "Unexpected overflow bit"
    (Overflow false r) -> toInt a + toInt b === toInt r

propLeftShift :: ArbByte -> Bit -> Result
propLeftShift (ArbByte b@(Byte (Nibble a0 a1 a2 a3) (Nibble a4 a5 a6 a7))) a8  =
  let (Overflow b0 (Byte (Nibble b1 b2 b3 b4) (Nibble b5 b6 b7 b8))) = leftShift a8 b
  in [a0, a1, a2, a3, a4, a5, a6, a7, a8] === [b0, b1, b2, b3, b4, b5, b6, b7, b8]

propRightShift :: Bit -> ArbByte -> Result
propRightShift a0 (ArbByte b@(Byte (Nibble a1 a2 a3 a4) (Nibble a5 a6 a7 a8))) =
  let (Overflow b8 (Byte (Nibble b0 b1 b2 b3) (Nibble b4 b5 b6 b7))) = rightShift a0 b
  in [a0, a1, a2, a3, a4, a5, a6, a7, a8] === [b0, b1, b2, b3, b4, b5, b6, b7, b8]