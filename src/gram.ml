
(* Compute a Gram matrix as fast as possible using parallelism *)

module L = BatList
module Log = Dolog.Log

let dot_product xs ys =
  let res = ref 0.0 in
  Array.iter2 (fun x y ->
      res := !res +. (x *. y)
    ) xs ys;
  !res

let compute_gram_matrix_seq () =
  failwith "not implemented yet"

let compute_gram_matrix_paramp () =
  failwith "not implemented yet"

let compute_gram_matrix_parany () =
  failwith "not implemented yet"

let compute_gram_matrix_multicore () =
  failwith "waiting for external contribution"

let compute_nb_features_max () =
  failwith "not implemented yet"

let read_one_line line =
  failwith "not implemented yet"

type style = Sequential
           | Par_Parmap
           | Par_Parany
           | Par_Multicore

let string_of_style = function
  | Sequential -> "seq"
  | Par_Parmap -> "parmap"
  | Par_Parany -> "parany"
  | Par_Multicore -> "multicore"

let main () =
  (* read data in *)
  let ncores = 1 in
  let csize = 1 in
  let nb_features = failwith "not implemented yet" in
  let samples = failwith "not implemented yet" in
  let ref_dt, ref_matrix =
    Gc.full_major ();
    Utls.wall_clock_time (fun () ->
        compute_gram_matrix_seq nb_features samples
      ) in
  L.iter (fun style ->
      let () = Gc.full_major () in
      let curr_dt, curr_matrix =
        Utls.wall_clock_time (fun () ->
            compute_gram_matrix_seq style nb_features samples
          ) in
      let style_name = string_of_style style in
      Utls.enforce (curr_matrix = ref_matrix)
        (style_name ^ ": matrix <> ref_matrix");
      Log.info "style: %s dt: %f accel: %.2f"
        style_name curr_dt (ref_dt /. curr_dt)
    ) [Par_Parmap; Par_Parany; Par_multicore];
  ()

let () = main ()
