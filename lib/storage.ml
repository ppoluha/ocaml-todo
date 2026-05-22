(* Persistence layer — load and save tasks as S-expressions *)

open Task

(** Default file path: ~/.todo.sexp *)
let default_path () =
  let home = Sys.getenv "HOME" in
  Filename.concat home ".todo.sexp"

(** Load tasks from disk. Returns an empty list if the file doesn't exist yet *)
let load path =
  if Sys.file_exists path then
    let contents = In_channel.with_open_text path In_channel.input_all in
    let sexp = Sexplib.Sexp.of_string contents in
    todo_list_of_sexp sexp
  else
    []

(** Save tasks to disk by converting to an S-expression string. *)
let save path (tasks : todo_list) =
  let sexp = sexp_of_todo_list tasks in
  let contents = Sexplib.Sexp.to_string_hum sexp in
  Out_channel.with_open_text path (fun oc ->
    Out_channel.output_string oc contents)
