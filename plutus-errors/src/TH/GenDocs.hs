{-# LANGUAGE TemplateHaskell #-}
{-# OPTIONS_HADDOCK hide #-}
module TH.GenDocs (genDocs) where

import           Data.List
import           Errors
import           Language.Haskell.TH as TH
import           TH.GenCodes
import ErrorCode
import qualified Data.Text.Prettyprint.Doc as PP

-- | Generate haddock documentation for all errors and their codes,
-- by creating type-synonyms to lifted dataconstructors using a DataKinds trick.
genDocs :: Q [TH.Dec]
genDocs = let allCodes = $(genCodes allErrors)
          in case findDuplicates allCodes of
                 []   -> pure $ fmap mkTySyn (zip allErrors allCodes)
                 -- Fail at compile time if duplicate error codes are found.
                 dups -> fail $ "ErrorCode instances have some duplicate error-code numbers: " ++ (show $ PP.pretty dups)

-- | An alias (type-synonym) for a given error,
-- using naming scheme "E+error-code".
mkTySyn :: (TH.Name,E) -> TH.Dec
mkTySyn (err, code) =
    let aliasName = mkName $ show $ PP.pretty code
    in TySynD aliasName [] $ ConT err

-- | find the duplicate occurences in a list
findDuplicates :: Ord a => [a] -> [[a]]
findDuplicates xs = filter (\g -> length g >1) . group $ sort xs
