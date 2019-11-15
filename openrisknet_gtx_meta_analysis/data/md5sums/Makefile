all: help

help:
	echo "Try make report for report"

report: ntc_wp411_e01.txt rieswijk_ntc_wp411_overlap.txt e_mexp_2636_md5sums.txt rieswijk_e_mexp_2636_overlap.txt km4_cmps_md5sums.txt rieswijk_km4_cmps_overlap.txt\
        km8_cmps_md5sums.txt rieswijk_km8_cmps_overlap.txt
	ntc_count=$$(wc -l ntc_wp411_e01.txt|cut -f1 -d' '); ntc_overlap=$$(wc -l rieswijk_ntc_wp411_overlap.txt|cut -f1 -d' ');\
	e2636_count=$$(wc -l e_mexp_2636_md5sums.txt|cut -f1 -d' '); e2636_overlap=$$(wc -l rieswijk_e_mexp_2636_overlap.txt|cut -f1 -d' ');\
	km8_count=$$(wc -l km8_cmps_md5sums.txt|cut -f1 -d' '); km8_overlap=$$(wc -l rieswijk_km8_cmps_overlap.txt|cut -f1 -d' ');\
	km4_count=$$(wc -l km4_cmps_md5sums.txt|cut -f1 -d' '); km4_overlap=$$(wc -l rieswijk_km4_cmps_overlap.txt|cut -f1 -d' ');\
	echo "experiment\ttotal\toverlap" > report.txt;\
	echo "NTC_WP_4.1.1_E01\t$${ntc_count}\t$${ntc_overlap}" >> report.txt;\
	echo "KM4_cmps\t$${km4_count}\t$${km4_overlap}" >> report.txt;\
	echo "KM8_cmps\t$${km8_count}\t$${km8_overlap}" >> report.txt;\
	echo "E2636\t$${e2636_count}\t$${e2636_overlap}" >> report.txt;\

clean:
	rm report.txt
