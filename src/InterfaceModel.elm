module InterfaceModel where

import Lang exposing (..)
import Eval
import Sync exposing (Triggers)
import Utils
import LangSvg exposing (IndexedTree, NodeId, ShapeKind, Attr, Zone)
import Examples

import List 
import Dict
import Debug
import String

import Svg
import Lazy

type alias Model =
  { scratchCode : String
  , exName : String
  , code : String
  , inputExp : Maybe Exp
  , rootId : NodeId
  , workingSlate : IndexedTree
  , mode : Mode
  , mouseMode : MouseMode
  , orient : Orientation
  , midOffsetX : Int  -- extra codebox width in vertical orientation
  , midOffsetY : Int  -- extra codebox width in horizontal orientation
  , showZones : Bool
  , syncOptions : Sync.Options
  , editingMode : Bool
  }

type Mode
  = AdHoc | SyncSelect Int PossibleChanges | Live Triggers
  | Print RawSvg

type alias RawSvg = String

type MouseMode
  = MouseNothing
  | MouseObject (NodeId, ShapeKind, Zone, Maybe (MouseTrigger (Exp, IndexedTree)))
  | MouseResizeMid (Maybe (MouseTrigger (Int, Int)))

type alias MouseTrigger a = (Int, Int) -> a

type Orientation = Vertical | Horizontal

type alias PossibleChanges =
  ( Int               -- num local changes
  , List (Exp, Val)   -- local changes ++ [structural change, revert change]
  )

type Event = CodeUpdate String
           | SelectObject Int ShapeKind Zone
           | MouseUp
           | MousePos (Int, Int)
           | Sync
           | TraverseOption Int -- offset from current index (+1 or -1)
           | SelectOption
           | SwitchMode Mode
           | SelectExample String (() -> {e:Exp, v:Val})
           | Edit
           | Run
           | ToggleOutput
           | ToggleZones
           | ToggleThawed
           | SwitchOrient
           | StartResizingMid
           | Noop

events : Signal.Mailbox Event
events = Signal.mailbox <| CodeUpdate ""

mkLive opts e v = Live <| Sync.prepareLiveUpdates opts e v
mkLive_ opts e  = mkLive opts e (Eval.run e)

sampleModel =
  let
    (name,f) = Utils.head_ Examples.list
    {e,v} = f ()
    (rootId,slate) = LangSvg.valToIndexedTree v
  in
    { scratchCode  = Examples.scratch
    , exName       = name
    , code         = sExp e
    , inputExp     = Just e
    , rootId       = rootId
    , workingSlate = slate
    , mode         = mkLive Sync.defaultOptions e v
    , mouseMode    = MouseNothing
    , orient       = Vertical
    , midOffsetX   = 0
    , midOffsetY   = -100
    , showZones    = False
    , syncOptions  = Sync.defaultOptions
    , editingMode  = False
    }
