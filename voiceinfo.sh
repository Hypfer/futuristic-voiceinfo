#!/bin/bash

#Benötigt: Fetchmail !!! ~/.netrc!!!!
#
#.netrc format
#machine imap.something.tld
#login username
#password sosecret
#
#
#svox-pico-git
#googlecl (Inkl oauth token..) Einmal so ausführen!

message="Hallo USER, "

speak() {
pico2wave -l=de-DE -w=/dev/shm/ttslolwut.wav "$1"
aplay /dev/shm/ttslolwut.wav 2>1 > /dev/null
rm -rf /dev/shm/ttslolwut.wav 2>1 > /dev/null

}

wetter() {

jsonwetter=`wget -qO - "http://api.openweathermap.org/data/2.5/weather?q=Berlin,Germany&lang=de&units=metric"`
wetter=`echo $jsonwetter | cut -d":" -f13 | cut -d"," -f1 | sed -e 's/\"//g'`
tempdraussen=`echo $jsonwetter | cut -d":" -f17 | cut -d"," -f1 | tr "." ","`
if [ -z "$wetter" ]; then
	wetter="Unbekannt"
fi
if [ -z "$tempdraussen" ]; then
	tempdraussen="Unbekannt"
fi

message+="Das Wetter ist $wetter bei $tempdraussen Grad. "

}

mailcount(){
mailcounts=`fetchmail -c -u "user" -p imap --ssl imap.something.tld | grep -E -o '[0-9]+'`
mailtotal=`echo $mailcounts | cut -d" " -f1`
mailread=`echo $mailcounts | cut -d" " -f2`
mailunread=$(($mailtotal - $mailread))
message+="sie haben $mailunread neue I-Mäils. "

}
googlecal(){

nexttermin=`google calendar list | head -n3 | tail -n1`
nexttermin1=`echo $nexttermin | cut -d"," -f1`
nexttermin3=`echo $nexttermin | cut -d"," -f2 | cut -d" " -f1`
nexttermin2=`echo $nexttermin | cut -d"," -f2 | cut -d" " -f2`
nexttermin4=`echo $nexttermin | cut -d"," -f2 | cut -d" " -f3`
nexttermin6=`echo $nexttermin | cut -d"," -f2 | cut -d" " -f5`
nexttermin5=`echo $nexttermin | cut -d"," -f2 | cut -d" " -f6`
nexttermin7=`echo $nexttermin | cut -d"," -f2 | cut -d" " -f7`

message+="Ihr nächster Termin ist $nexttermin1 vom $nexttermin2 ten $nexttermin3 um $nexttermin4 bis zum $nexttermin5 ten $nexttermin6 um $nexttermin7 . " 


}

mailcount
wetter
googlecal
speak "$message"
