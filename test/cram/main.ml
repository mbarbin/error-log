let write_cmd =
  Command.make
    ~summary:"write to an error-log"
    (let%map_open.Command config = Error_log.Config.arg
     and file = Arg.named [ "file" ] Param.string ~docv:"FILE" ~doc:"file"
     and line = Arg.named [ "line" ] Param.int ~docv:"N" ~doc:"line number"
     and pos_cnum = Arg.named [ "pos-cnum" ] Param.int ~docv:"N" ~doc:"character position"
     and pos_bol = Arg.named [ "pos-bol" ] Param.int ~docv:"N" ~doc:"beginning of line"
     and length = Arg.named [ "length" ] Param.int ~docv:"N" ~doc:"length of range"
     and message_kind =
       Arg.named_with_default
         [ "message-kind" ]
         (Param.enumerated (module Error_log.Message.Kind))
         ~default:Error_log.Message.Kind.Error
         ~docv:"KIND"
         ~doc:"message kind"
     and raise = Arg.flag [ "raise" ] ~doc:"raise an exception" in
     let loc =
       let p = { Lexing.pos_fname = file; pos_lnum = line; pos_cnum; pos_bol } in
       Loc.create (p, { p with pos_cnum = pos_cnum + length })
     in
     Error_log.report_and_exit' ~config (fun error_log ->
       if raise then failwith "Raising an exception!";
       match message_kind with
       | Error -> Error_log.error error_log ~loc [ Pp.text "error message" ]
       | Warning -> Error_log.warning error_log ~loc [ Pp.text "warning message" ]
       | Info -> Error_log.info error_log ~loc [ Pp.text "info message" ]
       | Debug -> Error_log.debug error_log ~loc [ Pp.text "debug message" ]))
;;

let main =
  Command.group ~summary:"test error-log from the command line" [ "write", write_cmd ]
;;

let () = Cmdlang_cmdliner_runner.run main ~name:"main" ~version:"%%VERSION%%"
