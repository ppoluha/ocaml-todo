(** CLI command parsing and execution. *)

open Task

(** The set of commands the user can issue. *)
type command =
  | Add of { title : string; priority : priority }
  | Complete of int          (* task id *)
  | Delete of int            (* task id *)
  | List of { filter : status option }  (* None = show all *)
  | Help

(** Generate the next available ID from the current task list. *)
let next_id (tasks : todo_list) =
  let max_id =
    List.fold_left (fun acc (t : task) -> max acc t.id) 0 tasks
  in
  max_id + 1

(** Parse a priority string into a priority.
    "function" is a shorthand for pattern matching on the last argument, ie let parse_priority p = match p with.
    In Java the return type would be Result<Priority, String> *)
let parse_priority = function
  | "low"    -> Ok Low
  | "medium" -> Ok Medium
  | "high"   -> Ok High
  | s        -> Error (Printf.sprintf "Unknown priority: %s (use low/medium/high)" s)

(** Parse command-line arguments into a command. *)
let parse_args (args : string list) : (command, string) result =
  match args with
  | ["add"; title] ->
    Ok (Add { title; priority = Medium })
  | ["add"; title; "-p"; p] ->
    (match parse_priority p with
     | Ok priority -> Ok (Add { title; priority })
     | Error e -> Error e)
  | ["complete"; id_str] ->
    (match int_of_string_opt id_str with
     | Some id -> Ok (Complete id)
     | None -> Error "Invalid task ID")
  | ["delete"; id_str] ->
    (match int_of_string_opt id_str with
     | Some id -> Ok (Delete id)
     | None -> Error "Invalid task ID")
  | ["list"] ->
    Ok (List { filter = None })
  | ["list"; "--done"] ->
    Ok (List { filter = Some Done })
  | ["list"; "--todo"] ->
    Ok (List { filter = Some Todo })
  | ["help"] | [] ->
    Ok Help
  | _ ->
    Error "Unknown command. Run with 'help' for usage."

(** Format a single task for display. *)
let format_task (t : task) =
  let status_str = match t.status with
    | Todo -> "[ ]"
    | Done -> "[x]"
  in
  let priority_str = match t.priority with
    | Low    -> "low"
    | Medium -> "med"
    | High   -> "HIGH"
  in
  Printf.sprintf "  %d. %s (%s) %s" t.id status_str priority_str t.title

(** Execute a command against a task list, return a new task list. *)
let execute (cmd : command) (tasks : todo_list) : todo_list =
  match cmd with
  | Add { title; priority } ->
    let new_task = {
      id = next_id tasks;
      title;
      status = Todo;
      priority;
    } in
    let updated = tasks @ [new_task] in (* new task is appended at the end, original list is copied. For better performance, use :: which prepends *)
    Printf.printf "Added: %s (id=%d)\n" title new_task.id;
    updated

  | Complete id ->
    let found = ref false in (* ref creates a reference, ie a mutable variable *)
    let updated = List.map (fun (t : task) ->
      if t.id = id then begin
        found := true;
        Printf.printf "Completed: %s\n" t.title;
        { t with status = Done }  (* record update — creates a NEW record *)
      end else
        t
    ) tasks in
    if not !found then
      Printf.printf "No task with id %d\n" id;
    updated

 (* See below for a more functional solution
 | Complete id ->
    let (updated_rev, found) = List.fold_left (fun (acc_list, acc_found) (t : task) ->
      if t.id = id then
        (( { t with status = Done } :: acc_list), true)
      else
        ((t :: acc_list), acc_found)
    ) ([], false) tasks in

    let updated = List.rev updated_rev in

    if not found then
      Printf.printf "No task with id %d\n" id
    else
      print_endline "Task completed.";
*)

  | Delete id ->
    let original_len = List.length tasks in
    let updated = List.filter (fun (t : task) -> t.id <> id) tasks in
    if List.length updated < original_len then
      Printf.printf "Deleted task %d\n" id
    else
      Printf.printf "No task with id %d\n" id;
    updated

  | List { filter } ->
    let filtered = match filter with
      | None -> tasks
      | Some s -> List.filter (fun (t : task) -> t.status = s) tasks
    in
    if filtered = [] then
      print_endline "  No tasks found."
    else
      List.iter (fun t -> print_endline (format_task t)) filtered;
    tasks  (* listing doesn't modify the task list *)

  | Help ->
    print_endline "Usage:";
    print_endline "  todo add \"Buy milk\"              Add a task (default: medium priority)";
    print_endline "  todo add \"Fix bug\" -p high       Add with priority (low/medium/high)";
    print_endline "  todo complete 1                   Mark task 1 as done";
    print_endline "  todo delete 1                     Remove task 1";
    print_endline "  todo list                         Show all tasks";
    print_endline "  todo list --done                  Show completed tasks";
    print_endline "  todo list --todo                  Show pending tasks";
    tasks
