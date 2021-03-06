module Main where

import Text
import Graphics.Element
import Dict
import String
import List
import Debug

import Lang exposing (..)
import LangParser
import Sync
import Utils

print = Graphics.Element.leftAligned << Text.monospace << Text.fromString

------------------------------------------------------------------------------

doExample e v v' =
  let s0 =
    Utils.lines [
        sExpLocsK 1 e ++ " ->* " ++ strValLocs v
      , ""
      , "Initial Program"
      , sExpK 1 e
      , ""
      , "Initial Result"
      , strVal v
      , ""
      , "Updated Result"
      , strVal v'
      ]
  in
  case Sync.sync e v v' of
    Err e -> print <| Utils.lines [s0, e]
    Ok l ->
      print <|
        Utils.lines [
          s0
        , ""
        , String.join "\n\n"
            (Utils.mapi (\(i,((ei,vi),vdiff)) ->
               "Option " ++ toString i ++ " "
               ++ Utils.parens ("vdiff = " ++ toString vdiff) ++ "\n"
               ++ sExpK 1 ei ++ " ->* " ++ strVal vi) l)
        ]

main =
  let {e,v,vnew} = MicroTests.test14 () in
  doExample e v vnew

