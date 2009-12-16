# GNUPlot command file for data in
# the file 'test/raw'
# Generated by ArchiveExport 2.7.0

set xlabel "Time [secs]"
set grid
set mxtics 2
set ylabel 'fred'
set y2label 'janet'
set y2tics

# When using the time formatting/parsing of gnuplot,
# the fractional seconds get truncated to full seconds,
# and then the linear interpol. values no longet line up
# nicely with the raw data.
# Convert by hand into seconds with 'using ...' directive:
plot 'test/raw' index 0 using ($4*3600.0+$5*60+$6-38860):7 "%lf/%lf/%lf %lf:%lf:%lf %lf" title 'fred [furlong]' with lines, 'test/lin' index 0 using ($4*3600.0+$5*60+$6-38860):7 "%lf/%lf/%lf %lf:%lf:%lf %lf" title 'linear' with points, 'test/avg' index 0 using ($4*3600.0+$5*60+$6-38860):7 "%lf/%lf/%lf %lf:%lf:%lf %lf" title 'average' with points, 'test/raw' index 1 using ($4*3600.0+$5*60+$6-38860):7 "%lf/%lf/%lf %lf:%lf:%lf %lf" axes x1y2 title 'janet [furlong]' with lines, 'test/lin' index 1 using ($4*3600.0+$5*60+$6-38860):7 "%lf/%lf/%lf %lf:%lf:%lf %lf" axes x1y2 title 'linear' with points, 'test/avg' index 1 using ($4*3600.0+$5*60+$6-38860):7 "%lf/%lf/%lf %lf:%lf:%lf %lf" axes x1y2 title 'average' with points

pause 5 "Please check picture"

set output '/tmp/combined.png'
set terminal png
replot

