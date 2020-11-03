program test_performance_db_generator;

type
 complaintT = record
  logno: word;          { log # }
  logty: char;          { log type (local/export) }
  logda: word;          { log date }
  logmo: word;          { log month }
  logyr: word;          { log yr }
  invno: string[20];    { invoice no }
  invda: string[20];    { invoice date }
  custn: string[80];    { customer name }
  prod1: string[80];    { product line 1 }
  prod2: string[80];    { .. }
  comp1: string[80];    { nature of complaint line 1 }
  comp2: string[80];    { .. }
  resp : string[40];    { responsibility }
  cost : real;          { cost impact }
  stats: boolean;       { status (open-1/closed-0) }
  rtime: integer;       { response time (days), -1 for NA }
  staff: string[64];    { sales person responsible }
  actpl: boolean;
 end;

var
 total, i: word;
 dbfilen: string;
 dbfile: file of complaintT;
 dbdata: complaintT;


function randstr(len: byte): string;
var
 i: byte;
 c: char;
 s: string;
 begin
  s := '';
  for i := 1 to len do
   begin
    c := '?';
    s := s + c;
   end;
  randstr := s;
 end;


begin
 writeln('Performance test database creator...');
 writeln;
 write('Filename of DB file? (Default: DATA.DA2): ');
 readln(dbfilen);
 writeln;
 write('No of records to create? (0-65535): ');
 readln(total);
 writeln;
 writeln('Creating...');

 assign(dbfile, dbfilen);
 rewrite(dbfile);

 for i := 1 to total do begin
  with dbdata do
   begin
    writeln('Adding record #', i);
    logno:= i;
    logty:= 'L';
    logda:= 99;
    logmo:= 99;
    logyr:= 9999;
    invno:= 'DUMMYINV';
    invda:= '00/00/0000';
    custn:= randstr(50);
    prod1:= randstr(50);
    prod2:= randstr(50);
    comp1:= randstr(50);
    comp2:= randstr(50);
    resp := randstr(30);
    cost := 123.123123;
    stats:= true;
    rtime:= 365;
    staff:= randstr(50);
    actpl:= true;
   end;
  write(dbfile, dbdata);
 end;

 close(dbfile);
 writeln('DONE!');

end.