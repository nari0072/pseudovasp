
      set format x "%.2e"

      set xlabel "a1"
      set ylabel "erg"
      plot "./k.txt" using 1:2 title "k" w lp

      replot "./k.txt" using 1:3 title "term 1" w lp

      replot "./k.txt" using 1:4 title "term 2" w lp

      replot "./k.txt" using 1:5 title "term 3" w lp

      replot "./k.txt" using 1:6 title "term 4" w lp

      