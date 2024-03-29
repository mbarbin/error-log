let write_cmd =
  Command.basic
    ~summary:"write to an error-log"
    (let%map_open.Command config = Error_log.Config.param
     and file = flag "--file" (required string) ~doc:"FILE file"
     and line = flag "--line" (required int) ~doc:"N line number"
     and pos_cnum = flag "--pos-cnum" (required int) ~doc:"N character position"
     and pos_bol = flag "--pos-bol" (required int) ~doc:"N beginning of line"
     and length = flag "--length" (required int) ~doc:"N length of range"
     and message_kind =
       flag
         "--message-kind"
         (optional_with_default
            Error_log.Message.Kind.Error
            (Arg_type.enumerated_sexpable (module Error_log.Message.Kind)))
         ~doc:"KIND message kind"
     and raise = flag "--raise" no_arg ~doc:"raise an exception" in
     let loc =
       let p = { Lexing.pos_fname = file; pos_lnum = line; pos_cnum; pos_bol } in
       Loc.create (p, { p with pos_cnum = pos_cnum + length })
     in
     Error_log.report_and_exit ~config (fun error_log ->
       if raise then failwith "Raising an exception!";
       (match message_kind with
        | Error -> Error_log.error error_log ~loc [ Pp.text "error message" ]
        | Warning -> Error_log.warning error_log ~loc [ Pp.text "warning message" ]
        | Info -> Error_log.info error_log ~loc [ Pp.text "info message" ]
        | Debug -> Error_log.debug error_log ~loc [ Pp.text "debug message" ]);
       return ()))
;;

let main =
  Command.group ~summary:"test error-log from the command line" [ "write", write_cmd ]
;;

let () =
  (* Non terminating expressions currently have to disable coverage, otherwise a
     non visitable coverage point is inserted. This issue has been reported
     upstream.

     {[
       let () = __bisect_post_visit__ 1 (Command_unix.run main)
     ]}

     https://github.com/mbarbin/error-log/issues/2
  *)
  (Command_unix.run main [@coverage off])
;;
