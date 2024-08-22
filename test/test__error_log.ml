open! Or_error.Let_syntax

let%expect_test "return" =
  Error_log.For_test.report' (fun error_log -> ignore (error_log : Error_log.t));
  [%expect {||}];
  ()
;;

let%expect_test "return Ok" =
  Error_log.For_test.report (fun error_log ->
    ignore (error_log : Error_log.t);
    return ());
  [%expect {||}];
  ()
;;

let%expect_test "return Error" =
  Error_log.For_test.report (fun error_log ->
    ignore (error_log : Error_log.t);
    Or_error.error_s [%sexp "Error message"]);
  [%expect {|
    "Error message"
    [1] |}];
  ()
;;

let%expect_test "default mode" =
  let config = Error_log.Config.create () in
  Error_log.For_test.report ~config (fun error_log ->
    print_s [%sexp (Error_log.mode error_log : Error_log.Config.Mode.t)];
    [%expect {| Default |}];
    print_s [%sexp (Error_log.is_debug_mode error_log : bool)];
    [%expect {| false |}];
    return ());
  [%expect {||}];
  ()
;;

let%expect_test "debug mode" =
  let config = Error_log.Config.create ~mode:Debug () in
  Error_log.For_test.report ~config (fun error_log ->
    print_s [%sexp (Error_log.mode error_log : Error_log.Config.Mode.t)];
    [%expect {| Debug |}];
    print_s [%sexp (Error_log.is_debug_mode error_log : bool)];
    [%expect {| true |}];
    return ());
  [%expect {||}];
  ()
;;

let%expect_test "dump config" =
  let config = Error_log.Config.create ~mode:Debug () in
  print_s [%sexp (config : Error_log.Config.t)];
  [%expect {|
    ((mode       Debug)
     (warn_error false)) |}];
  ()
;;

let%expect_test "uncaught exception" =
  require_does_raise [%here] (fun () ->
    Error_log.For_test.report (fun (_ : Error_log.t) -> raise_s [%sexp Exception]));
  [%expect {| Exception |}];
  ()
;;

let path = Fpath.(v "my-file.ext")

let%expect_test "raise" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  Error_log.For_test.report (fun error_log ->
    Error_log.raise
      error_log
      ~loc
      [ Pp.textf "This is an error with some %s message." "error"
      ; Pp.textf "Unbound value 'vra'"
      ]
      ~hints:
        (Pp.text "And some hints too"
         :: Error_log.did_you_mean "vra" ~candidates:[ "var"; "hello"; "world" ]));
  [%expect
    {|
    File "my-file.ext", line 3, characters 0-0:
    Error: This is an error with some error message.
    Unbound value 'vra'
    Hint: And some hints too
    Hint: did you mean var?
    [1] |}];
  ()
;;

let%expect_test "error" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  Error_log.For_test.report (fun error_log ->
    Error_log.error
      error_log
      ~loc:(Loc.in_file_at_line ~path ~line:1)
      [ Pp.textf
          "Error log allows you to report several errors if you want to, rather than \
           stopping the execution at the first one."
      ];
    Error_log.error
      error_log
      ~loc
      [ Pp.textf "This is an error with some %s message." "error"
      ; Pp.textf "Unbound value 'vra'"
      ]
      ~hints:
        (Pp.text "And some hints too"
         :: Error_log.did_you_mean "vra" ~candidates:[ "var"; "hello"; "world" ]);
    return ());
  [%expect
    {|
    File "my-file.ext", line 1, characters 0-0:
    Error: Error log allows you to report several errors if you want to, rather
    than stopping the execution at the first one.
    File "my-file.ext", line 3, characters 0-0:
    Error: This is an error with some error message.
    Unbound value 'vra'
    Hint: And some hints too
    Hint: did you mean var?
    [1] |}];
  ()
;;

let%expect_test "warning" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  let config = Error_log.Config.create () in
  Error_log.For_test.report ~config (fun error_log ->
    Error_log.warning
      error_log
      ~loc
      [ Pp.textf "This is an warning with some %s message." "warning"
      ; Pp.textf "Unbound value 'vra'"
      ]
      ~hints:
        (Pp.text "And some hints too"
         :: Error_log.did_you_mean "vra" ~candidates:[ "var"; "hello"; "world" ]);
    return ());
  [%expect
    {|
    File "my-file.ext", line 3, characters 0-0:
    Warning: This is an warning with some warning message.
    Unbound value 'vra'
    Hint: And some hints too
    Hint: did you mean var? |}];
  ()
;;

let%expect_test "warn-error" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  let config = Error_log.Config.create ~warn_error:true () in
  Error_log.For_test.report ~config (fun error_log ->
    Error_log.warning error_log ~loc [ Pp.textf "Hi" ];
    return ());
  [%expect {|
    File "my-file.ext", line 3, characters 0-0:
    Warning: Hi
    [1] |}];
  ()
;;

let%expect_test "warning when quiet" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  let config = Error_log.Config.create ~mode:Quiet () in
  Error_log.For_test.report ~config (fun error_log ->
    Error_log.warning error_log ~loc [ Pp.textf "Hi" ];
    return ());
  [%expect {||}];
  ()
;;

let%expect_test "warn-error when quiet" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  let config = Error_log.Config.create ~mode:Quiet ~warn_error:true () in
  Error_log.For_test.report ~config (fun error_log ->
    Error_log.warning error_log ~loc [ Pp.textf "Hi" ];
    return ());
  [%expect {|
    File "my-file.ext", line 3, characters 0-0:
    Warning: Hi
    [1] |}];
  ()
;;

let%expect_test "info & debug" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  let config = Error_log.Config.create () in
  Error_log.For_test.report ~config (fun error_log ->
    Error_log.info error_log ~loc [ Pp.textf "Hi" ];
    Error_log.debug error_log ~loc [ Pp.textf "Debug!!" ];
    return ());
  [%expect {||}];
  ()
;;

let%expect_test "info & debug when verbose" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  let config = Error_log.Config.create ~mode:Verbose () in
  Error_log.For_test.report ~config (fun error_log ->
    Error_log.info error_log ~loc [ Pp.textf "Hi" ];
    Error_log.debug error_log ~loc [ Pp.textf "Debug!!" ];
    return ());
  [%expect {|
    File "my-file.ext", line 3, characters 0-0:
    Info: Hi |}];
  ()
;;

let%expect_test "info & debug when debug" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  let config = Error_log.Config.create ~mode:Debug () in
  Error_log.For_test.report ~config (fun error_log ->
    Error_log.info error_log ~loc [ Pp.textf "Hi" ];
    Error_log.debug error_log ~loc [ Pp.textf "Debug!!" ];
    return ());
  [%expect
    {|
    File "my-file.ext", line 3, characters 0-0:
    Info: Hi
    File "my-file.ext", line 3, characters 0-0:
    Debug: Debug!! |}];
  ()
;;

let%expect_test "protect" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  Error_log.For_test.report (fun error_log ->
    (match Error_log.protect error_log ~f:(fun () -> ()) with
     | Ok () -> ()
     | Error (_ : Error_log.Err.t) -> assert false);
    Error_log.error error_log ~loc [ Pp.textf "Error 1" ];
    (match
       Error_log.protect error_log ~f:(fun () ->
         Error_log.error error_log ~loc [ Pp.textf "Error 2" ];
         Error_log.raise error_log ~loc [ Pp.textf "Error 3" ])
     with
     | Ok () -> assert false
     | Error (_ : Error_log.Err.t) ->
       Error_log.error error_log ~loc [ Pp.textf "Error 4" ]);
    return ());
  [%expect
    {|
    File "my-file.ext", line 3, characters 0-0:
    Error: Error 1
    File "my-file.ext", line 3, characters 0-0:
    Error: Error 2
    File "my-file.ext", line 3, characters 0-0:
    Error: Error 3
    File "my-file.ext", line 3, characters 0-0:
    Error: Error 4
    [1] |}];
  ()
;;

(* Exceptions other than [Error_log.E] raised during [protect] are propagated.
   They do not affect the returned exit code if properly caught. *)
let%expect_test "protect raised" =
  Error_log.For_test.report (fun error_log ->
    match Error_log.protect error_log ~f:(fun () -> raise_s [%sexp Exception]) with
    | Ok () | Error (_ : Error_log.Err.t) -> assert false
    | exception e ->
      print_s [%sexp "Uncaught exception", (e : Exn.t)];
      return ());
  [%expect {| ("Uncaught exception" Exception) |}];
  ()
;;

(* As long as [Error_log.raise] was executed, the exit code will be that of a
   failing command, even if the exception is caught to run some extra logic. *)
let%expect_test "recovering from error" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  Error_log.For_test.report (fun error_log ->
    (match Error_log.raise error_log ~loc [ Pp.textf "Fatal error" ] with
     | () -> assert false
     | exception Error_log.E (_ : Error_log.Err.t) ->
       print_endline "Fatal error was caught, running some extra logic.");
    return ());
  [%expect
    {|
    Fatal error was caught, running some extra logic.
    File "my-file.ext", line 3, characters 0-0:
    Error: Fatal error
    [1] |}];
  ()
;;

let%expect_test "recover and reraise" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  Error_log.For_test.report (fun error_log ->
    match Error_log.raise error_log ~loc [ Pp.textf "Fatal error" ] with
    | () -> assert false
    | exception Error_log.E e ->
      print_endline "Fatal error was caught, running some extra logic.";
      Error_log.reraise e);
  [%expect
    {|
    Fatal error was caught, running some extra logic.
    File "my-file.ext", line 3, characters 0-0:
    Error: Fatal error
    [1] |}];
  ()
;;

let%expect_test "checkpoint" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  Error_log.For_test.report (fun error_log ->
    let%bind () = Error_log.checkpoint error_log in
    Error_log.error error_log ~loc [ Pp.text "Error 1" ];
    [%expect {||}];
    match Error_log.checkpoint error_log with
    | Ok () -> assert false
    | Error _ as err -> err);
  [%expect
    {|
    File "my-file.ext", line 3, characters 0-0:
    Error: Error 1
    [1] |}];
  ()
;;

let%expect_test "checkpoint_exn" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  let config = Error_log.Config.create ~warn_error:true () in
  Error_log.For_test.report ~config (fun error_log ->
    Error_log.checkpoint_exn error_log;
    Error_log.warning error_log ~loc [ Pp.text "Warning 1" ];
    match Error_log.checkpoint_exn error_log with
    | () -> assert false);
  [%expect
    {|
    File "my-file.ext", line 3, characters 0-0:
    Warning: Warning 1
    [1] |}];
  ()
;;

let%expect_test "flush" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  Error_log.For_test.report (fun error_log ->
    Error_log.error error_log ~loc [ Pp.text "Error 1" ];
    [%expect {||}];
    Error_log.error error_log ~loc [ Pp.text "Error 2" ];
    [%expect {||}];
    Error_log.flush error_log;
    [%expect
      {|
      File "my-file.ext", line 3, characters 0-0:
      Error: Error 1
      File "my-file.ext", line 3, characters 0-0:
      Error: Error 2 |}];
    Error_log.error error_log ~loc [ Pp.text "Error 3" ];
    [%expect {||}];
    return ());
  [%expect
    {|
    File "my-file.ext", line 3, characters 0-0:
    Error: Error 3
    [1] |}];
  ()
;;

let%expect_test "config param" =
  let configs =
    let%map.List warn_error = [ false; true ]
    and mode = Error_log.Config.Mode.all in
    Error_log.Config.create ~mode ~warn_error ()
  in
  List.iter configs ~f:(fun t ->
    let args = Error_log.Config.to_args t in
    let t' = Command.Param.parse Error_log.Config.param args |> Or_error.ok_exn in
    require_equal [%here] (module Error_log.Config) t t')
;;

let%expect_test "dump the log" =
  let loc = Loc.in_file_at_line ~path ~line:3 in
  Error_log.For_test.report (fun error_log ->
    Error_log.error error_log ~loc [ Pp.text "E" ];
    print_s [%sexp (error_log : Error_log.t)];
    [%expect
      {|
      ((config (
         (mode       Default)
         (warn_error false)))
       (messages ((
         (kind    Error)
         (message <opaque>)
         (flushed false))))) |}];
    Error_log.warning error_log ~loc [ Pp.text "W" ];
    print_s [%sexp (error_log : Error_log.t)];
    [%expect
      {|
      ((config (
         (mode       Default)
         (warn_error false)))
       (messages (
         ((kind Error)   (message <opaque>) (flushed false))
         ((kind Warning) (message <opaque>) (flushed false))))) |}];
    Error_log.flush error_log;
    [%expect
      {|
      File "my-file.ext", line 3, characters 0-0:
      Error: E
      File "my-file.ext", line 3, characters 0-0:
      Warning: W |}];
    Error_log.info error_log ~loc [ Pp.text "I" ];
    Error_log.debug error_log ~loc [ Pp.text "D" ];
    print_s [%sexp (error_log : Error_log.t)];
    [%expect
      {|
      ((config (
         (mode       Default)
         (warn_error false)))
       (messages (
         ((kind Error)   (message <opaque>) (flushed true))
         ((kind Warning) (message <opaque>) (flushed true))
         ((kind Info)    (message <opaque>) (flushed false))
         ((kind Debug)   (message <opaque>) (flushed false))))) |}];
    return ());
  [%expect {| [1] |}];
  ()
;;

let%expect_test "am_running_test" =
  let am_running_test () =
    print_s [%sexp { am_running_test = (Error_log.am_running_test () : bool) }]
  in
  am_running_test ();
  [%expect {| ((am_running_test false)) |}];
  Error_log.For_test.report (fun (_ : Error_log.t) ->
    am_running_test ();
    [%expect {| ((am_running_test true)) |}];
    return ());
  am_running_test ();
  [%expect {| ((am_running_test false)) |}];
  ()
;;
