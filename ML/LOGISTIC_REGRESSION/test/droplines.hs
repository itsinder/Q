#!/usr/bin/env stack
-- stack --resolver lts-2.9 --install-ghc runghc --package split

import Data.List.Split
import Data.List

dropLines fname = do
  trainData <- readFile ("mnist/" ++ fname ++ ".csv")
  let trainParsed = unlines . map (intercalate "," . drop 10 . splitOn ",") $ lines trainData
  writeFile ("mnist/" ++ fname ++ "_dropped.csv") trainParsed

main = do
  dropLines "train_data"
  dropLines "test_data"
