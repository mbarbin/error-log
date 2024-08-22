(** Error_log is an abstraction used by programs that process user programs and
    report located errors and warnings.

    The canonical syntax for an error produced by this lib is:

    {[
      File "my-file", line 42, character 11-15:
      Error: Some message that gives a general explanation of the issue.
      Followed by more details, perhaps some sexps, etc.
      ((A sexp)(with more)(details)
       (such_as
        (extra_values)))
    ]}

    It is inspired by dune's user_messages and uses dune's error message
    rendering under the hood. *)

type t [@@deriving sexp_of]

module Style : sig
  type t
end

(** Print a message with the prefix: "Warning:". Warning may not be displayed
    depending on the command params. By default, they are printed to stderr, and
    do not affect the exit code of the application (it will be 0 if there are
    no other errors). *)
val warning : t -> ?loc:Loc.t -> ?hints:Style.t Pp.t list -> Style.t Pp.t list -> unit

(** Print a message with the prefix: "Error:". The presence of errors will cause
    the final exit code to be 1. Note that this function returns [unit], so you
    may report multiple errors instead of stopping at the first one. If you
    want to still break the flow of execution after reporting multiple errors,
    see {!val:checkpoint}. If you are looking for a function to raise and bail out,
    see {!val:raise}. *)
val error : t -> ?loc:Loc.t -> ?hints:Style.t Pp.t list -> Style.t Pp.t list -> unit

(** Same as {!val:error} but raises and stops the execution at this error. This
    is more convenient to use than {!val:error} in code places where it's not easy
    to return anything meaningful in case of a fatal error. Under the hood
    this will raise the exception {!exception:E} that is caught by the
    enclosing {!val:report_and_exit}. *)
val raise : t -> ?loc:Loc.t -> ?hints:Style.t Pp.t list -> Style.t Pp.t list -> 'a

(** Print a message with the prefix: "Info:". This is only printed when in mode
    verbose. *)
val info : t -> ?loc:Loc.t -> ?hints:Style.t Pp.t list -> Style.t Pp.t list -> unit

(** Print a message with the prefix: "Debug:". This is only printed when in mode
    debug. *)
val debug : t -> ?loc:Loc.t -> ?hints:Style.t Pp.t list -> Style.t Pp.t list -> unit

(** Produces a "Did you mean ...?" hint (useful for typos). *)
val did_you_mean : string -> candidates:string list -> Style.t Pp.t list

(** [checkpoint] will return [Error e] if the error log has seen errors
    previously (warnings don't count, unless in warn-error mode). [e] only
    contains a simple statement, so it is not meant to replace the contents of
    the log, but simply to be passed forward to prevent other parts of the
    program from running.

    This is useful if you are trying not to stop at the first error encountered,
    but still want to stop the execution at a specific breakpoint after some
    numbers of errors. To be used in places where it is more wise to stop the
    flow at a given point rather than returning meaningless data. *)
val checkpoint : t -> unit Or_error.t

(** Same as {!val:checkpoint} but raises {!exception:E} if the error log has seen
    errors or warn-errors previously. *)
val checkpoint_exn : t -> unit

(** [flush t] prints to stderr all the messages currently available. This is
    useful for commands that have multiple parts, such as the bopkit
    simulator. Indeed, we want to produce all warnings on stderr prior to
    starting the simulation, rather than waiting until the very end of the
    simulation to produce all enqueued messages then. *)
val flush : t -> unit

module Config : sig
  module Mode : sig
    type t =
      | Quiet
      | Default
      | Verbose
      | Debug
    [@@deriving compare, equal, enumerate, sexp_of]
  end

  type t [@@deriving equal, sexp_of]

  val default : t
  val arg : t Commandlang.Command.Arg.t
  val create : ?mode:Mode.t -> ?warn_error:bool -> unit -> t

  (** Returns the arguments to supply to the command line to create [t]. *)
  val to_args : t -> string list

  (** [param] is kept for compatibility with older projects during a transition
      period, however please note it will be removed in a future version of
      [Error_log], in favor or [arg] only (commandlang). *)
  val param : t Command.Param.t
end

val mode : t -> Config.Mode.t
val is_debug_mode : t -> bool

(** Wrap the execution of a program and introduce an error log to the scope.
    This is meant to be used inside the body of a core command. This will take
    care of printing the error log to stderr and handle the command exit code. *)
val report_and_exit : config:Config.t -> (t -> unit Or_error.t) -> unit

(** Same but not using the Or_error monad. Currently experimenting. *)
val report_and_exit' : config:Config.t -> (t -> unit) -> unit

module For_test : sig
  (** Same as {!val:report_and_exit}, but won't exit, rather print the return
      code [1] at the end in case of an error, like in cram tests. *)
  val report : ?config:Config.t -> (t -> unit Or_error.t) -> unit

  (** Same but not using the [Or_error] monad. *)
  val report' : ?config:Config.t -> (t -> unit) -> unit
end

(** Returns [true] if we are inside a call to [For_test.report]. *)
val am_running_test : unit -> bool

module Message : sig
  module Kind : sig
    type t =
      | Error
      | Warning
      | Info
      | Debug
    [@@deriving equal, enumerate, sexp_of]

    val to_string : t -> string

    (** Tell whether a message of this kind should be printed or silenced under
        the specified configuration. *)
    val is_printed : t -> config:Config.t -> bool
  end
end

(** {1 Recovering from errors} *)

(** Sometimes you want to be able to catch fatal errors raised by some code, so
    you may continue to run some logic afterwards. This is what this part of
    the API is about.

    An important note though, even if you catch an exception {!exception:E}, and
    do not re-raise it afterwards, the resulting exit code reported by
    {!val:report_and_exit} will still be that of an error code.

    This is only intended to be used in places where you want to run a bit of
    extra logic after catching an error, but not to turn a fatal error into a
    success. *)

module Err : sig
  (** The type of errors raised by {!raise}. *)
  type t
end

exception E of Err.t

(** Re-raise an error originally raised by {!raise}. This is useful when you want
    to catch an error, run some extra logic, and then reraise the error when
    you are done. *)
val reraise : Err.t -> _

(** [protect t ~f] returns [Ok (f ())] with its results, or [Error err] if [f]
    raises {!exception:E}. This will only catch exceptions raised by {!raise}
    during the execution of [f], but not protect from any other exceptions :
    if [f] raises any other exception, this function will raise too. You may
    call {!val:reraise} on the returned [Err.t] to propagate the error further
    if you need to. *)
val protect : t -> f:(unit -> 'a) -> ('a, Err.t) Result.t
