10 PRINT "setting colour attributes"
30 for ov = 0 to 255
40 PRINT "commencing iteration " OV
60 for A = 0 to 27
65 for b = 0 to 255
70 PRINT "a:" A  "b:" b
80 OUT &H40, A
90 OUT &H41, B
100 OUT &H42, OV
115 next b
120 next a
130 next ov