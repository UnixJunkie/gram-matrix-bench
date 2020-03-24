# gram-matrix-bench

Performance benchmark for Parmap, Parany and Multicore-OCaml

Cf. https://en.wikipedia.org/wiki/Gramian_matrix

Run example:

```
./gram -np 2,3,4,5,6,7,8,9,10,11,12,13,14,15,16 \
       -i data/tox21_nrar_ligands_std_rand_01.csv
2020-03-24 17:32:56.773 INFO : samples: 7026 features: 1972
 48.00   18.00    4.00  ...      16.00   15.00    8.00
 18.00   28.00    5.00  ...      24.00    8.00    7.00
  4.00    5.00   40.00  ...      12.00   28.00   38.00
                        ...
 16.00   24.00   12.00  ...      64.00   16.00   16.00
 15.00    8.00   28.00  ...      16.00   54.00   34.00
  8.00    7.00   38.00  ...      16.00   34.00   72.00
2020-03-24 17:33:54.349 INFO : n: 1 c: 1 s: seq dt: 57.55 a: 1.00
2020-03-24 17:34:27.840 INFO : n: 2 c: 1 s: parmap dt: 33.34 a: 1.73
2020-03-24 17:34:59.823 INFO : n: 2 c: 1 s: parany dt: 30.97 a: 1.86
2020-03-24 17:35:26.434 INFO : n: 3 c: 1 s: parmap dt: 25.99 a: 2.21
2020-03-24 17:35:49.262 INFO : n: 3 c: 1 s: parany dt: 21.66 a: 2.66
2020-03-24 17:36:11.107 INFO : n: 4 c: 1 s: parmap dt: 21.32 a: 2.70
2020-03-24 17:36:28.944 INFO : n: 4 c: 1 s: parany dt: 16.97 a: 3.39
2020-03-24 17:36:48.656 INFO : n: 5 c: 1 s: parmap dt: 19.21 a: 3.00
2020-03-24 17:37:03.939 INFO : n: 5 c: 1 s: parany dt: 14.26 a: 4.04
2020-03-24 17:37:21.809 INFO : n: 6 c: 1 s: parmap dt: 17.37 a: 3.31
2020-03-24 17:37:35.275 INFO : n: 6 c: 1 s: parany dt: 12.36 a: 4.65
2020-03-24 17:37:52.094 INFO : n: 7 c: 1 s: parmap dt: 16.33 a: 3.52
2020-03-24 17:38:04.589 INFO : n: 7 c: 1 s: parany dt: 11.25 a: 5.12
2020-03-24 17:38:20.118 INFO : n: 8 c: 1 s: parmap dt: 15.15 a: 3.80
2020-03-24 17:38:31.048 INFO : n: 8 c: 1 s: parany dt: 10.05 a: 5.72
2020-03-24 17:38:45.725 INFO : n: 9 c: 1 s: parmap dt: 14.31 a: 4.02
2020-03-24 17:38:56.283 INFO : n: 9 c: 1 s: parany dt: 9.62 a: 5.98
2020-03-24 17:39:11.365 INFO : n: 10 c: 1 s: parmap dt: 14.72 a: 3.91
2020-03-24 17:39:22.130 INFO : n: 10 c: 1 s: parany dt: 9.87 a: 5.83
2020-03-24 17:39:36.473 INFO : n: 11 c: 1 s: parmap dt: 13.94 a: 4.13
2020-03-24 17:39:46.659 INFO : n: 11 c: 1 s: parany dt: 9.29 a: 6.19
2020-03-24 17:40:00.062 INFO : n: 12 c: 1 s: parmap dt: 12.99 a: 4.43
2020-03-24 17:40:09.765 INFO : n: 12 c: 1 s: parany dt: 8.84 a: 6.51
2020-03-24 17:40:23.097 INFO : n: 13 c: 1 s: parmap dt: 12.80 a: 4.50
2020-03-24 17:40:31.947 INFO : n: 13 c: 1 s: parany dt: 8.03 a: 7.16
2020-03-24 17:40:44.792 INFO : n: 14 c: 1 s: parmap dt: 12.47 a: 4.62
2020-03-24 17:40:53.150 INFO : n: 14 c: 1 s: parany dt: 7.58 a: 7.59
2020-03-24 17:41:05.684 INFO : n: 15 c: 1 s: parmap dt: 12.16 a: 4.73
2020-03-24 17:41:13.609 INFO : n: 15 c: 1 s: parany dt: 7.07 a: 8.14
2020-03-24 17:41:25.252 INFO : n: 16 c: 1 s: parmap dt: 11.27 a: 5.11
2020-03-24 17:41:33.760 INFO : n: 16 c: 1 s: parany dt: 7.76 a: 7.42

```
