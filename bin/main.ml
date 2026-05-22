(** Entry point *)

open Todo_lib

let () =
  let args = Sys.argv |> Array.to_list |> List.tl in
  let path = Storage.default_path () in
  match Command.parse_args args with
  | Error msg ->
    Printf.eprintf "Error: %s\n" msg;
    exit 1
  | Ok cmd ->
    let tasks = Storage.load path in
    let updated = Command.execute cmd tasks in
    Todo_lib.Storage.save path updated


