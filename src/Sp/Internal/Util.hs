module Sp.Internal.Util (Any, pattern Any, fromAny, DictRep, reflectDict) where

import           Data.Kind     (Constraint, Type)
import           GHC.Exts      (Any)
import           Unsafe.Coerce (unsafeCoerce)

-- | Coerce any boxed value into and from 'Any'. This is generally unsafe and it is your responsibility to ensure
-- that the type you're coercing into is the original type that the 'Any' value is coerced from.
pattern Any :: ∀ a. a -> Any
pattern Any x <- (unsafeCoerce -> x)
  where Any x = unsafeCoerce x
{-# COMPLETE Any #-}

-- | Coerce an 'Any' value to a certain type. This is generally unsafe and it is your responsibility to ensure
-- that the type you're coercing into is the original type that the 'Any' value is coerced from.
fromAny :: Any -> a
fromAny (Any x) = x

newtype DictMagic c a = DictMagic (c => a)

-- | The dictionary representation of a typeclass, such that @c => a@ and @DictRep c -> a@ have the same Core
-- representation. This is highly implementation-dependent, and there is currently only one case that is guaranteed to
-- hold: the representation of a single-method typeclass @class C where x :: A@ can always be any @B@ such that
-- @Coercible A B@.
type family DictRep (c :: Constraint) :: Type

-- | Reflect a dictionary representation into a value that receives a typeclass instance.
reflectDict :: ∀ c a. (c => a) -> DictRep c -> a
reflectDict x = unsafeCoerce (DictMagic @c @a x)
