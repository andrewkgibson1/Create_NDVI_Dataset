****haversine macro;

%macro haver_akg(lat1, long1, lat2, long2);
data _null_;
pi=constant("pi");
***Need to convert decimal degress to radians for this to work correctly;
lat2x=&lat2*pi/180;
lat1x=&lat1*pi/180;
long1x=&long1*pi/180;
long2x=&long2*pi/180;

diff1 = lat2x - lat1x;
diff2 = long2x - long1x;

part1 = sin(diff1/2)**2;
part2 = cos(lat1x)*cos(lat2x);
part3 = sin(diff2/2)**2;

a=part1 + part2*part3;
c=2*atan2(sqrt(a),sqrt(1-a));

*6372.8 km of earth radius;
*output in kilometers;
*divide radius by 1.609344 for distance in miles;
*multiply radius by 1000 for distance in meters;
radius = 6372.8;
dist3=c*(radius);
run;
%mend haver_akg;

%haver_akg(50.6610985,-128.1580048,50.6610985,-128.1080017)

data _null_;
put dist3;
run;

data _null_;
a= geodist(50.6610985,-128.1580048,50.6610985,-128.1080017);
put a;
run;
