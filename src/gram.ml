
(* Compute a Gram matrix as fast as possible using parallelization *)

open Printf

module A = BatArray
module CLI = Minicli.CLI
module L = BatList
module Log = Dolog.Log

let dot_product xs ys =
  let res = ref 0.0 in
  A.iter2 (fun x y ->
      res := !res +. (x *. y)
    ) xs ys;
  !res

type style = Sequential
           | Par_Parmap
           | Par_Parany
           | Par_Multicore

let string_of_style = function
  | Sequential -> "seq"
  | Par_Parmap -> "parmap"
  | Par_Parany -> "parany"
  | Par_Multicore -> "multicore"

let compute_gram_matrix style samples =
  assert(A.length samples > 0);
  Log.info "samples: %d features: %d"
    (A.length samples) (A.length samples.(0));
  match style with
  | Sequential ->
    begin
      let n = A.length samples in
      let res = A.init n (fun _ -> A.create_float n) in
      for i = 0 to n - 1 do
        for j = i to n - 1 do
          let x = dot_product samples.(i) samples.(j) in
          res.(i).(j) <- x;
          res.(j).(i) <- x (* the matrix is symmetric *)
        done
      done;
      res
    end
  | Par_Parmap
  | Par_Parany
  | Par_Multicore ->
    failwith "not implemented yet"

let parse_line line =
  let int_strings = BatString.split_on_char ' ' line in
  let nb_features = L.length int_strings in
  let res = A.create_float nb_features in
  L.iteri (fun i int_str ->
      A.unsafe_set res i (float_of_string int_str)
    ) int_strings;
  res

let main () =
  Log.color_on ();
  Log.set_log_level Log.INFO;
  let argc, args = CLI.init () in
  let show_help = CLI.get_set_bool ["-h";"--help"] args in
  if argc = 1 || show_help then
    (eprintf "usage:\n\
              %s -i <data.csv>\n  \
              [-h|--help]: show this help message\n"
       Sys.argv.(0);
     exit 1);
  let input_fn = CLI.get_string ["-i"] args in
  let ncores = CLI.get_int_def ["-np"] args 1 in
  let csize = CLI.get_int_def ["-c"] args 1 in
  CLI.finalize ();
  (* read data in *)
  let samples = A.of_list (Utls.map_on_lines_of_file input_fn parse_line) in
  let ref_dt, ref_matrix =
    Gc.full_major ();
    Utls.wall_clock_time (fun () ->
        compute_gram_matrix Sequential samples
      ) in
  Log.info "np: %d cs: %d style: %s dt: %f accel: %.2f"
    ncores csize "seq" ref_dt 1.0;
  (* TODO: print corners of the ref matrix *)
  L.iter (fun style ->
      let () = Gc.full_major () in
      let curr_dt, curr_matrix =
        Utls.wall_clock_time (fun () ->
            compute_gram_matrix style samples
          ) in
      let style_name = string_of_style style in
      Utls.enforce (curr_matrix = ref_matrix)
        (style_name ^ ": matrix <> ref_matrix");
      Log.info "np: %d csize: %d style: %s dt: %f accel: %.2f"
        ncores csize style_name curr_dt (ref_dt /. curr_dt)
    ) [Par_Parmap; Par_Parany; Par_Multicore];
  ()

let () = main ()
