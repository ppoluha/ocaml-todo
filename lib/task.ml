(* The task types *)

open Sexplib.Std

type status =
  | Todo
  | Done
[@@deriving sexp]

type priority =
  | Low
  | Medium
  | High
[@@deriving sexp]

type task = {
  id : int;
  title : string;
  status : status;
  priority : priority;
}
[@@deriving sexp]

type todo_list = task list
[@@deriving sexp]
