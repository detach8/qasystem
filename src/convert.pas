program convert;

uses crt;

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
 complaintT2 = record
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
  comp3: string[80];
  resp : string[40];    { responsibility }
  cost : real;          { cost impact }
  stats: boolean;       { status (open-1/closed-0) }
  rtime: integer;       { response time (days), -1 for NA }
  staff: string[64];    { sales person responsible }
  actpl: boolean;
 end;

var
 file1: file of complaintT;
 file2: file of complaintT2;
 data1: complaintT;
 data2: complaintT2;

begin
 writeln('YENOM QA SYSTEM DATABASE DBV2 TO DBV3 CONVERSION');
 writeln;
 writeln('Converting DATA.DA2 to DATA.DA3');
 writeln;
 assign(file1, 'DATA.DA2');
 assign(file2, 'DATA.DA3');
 reset(file1);
 rewrite(file2);

 while not eof(file1) do
  begin
   read(file1, data1);
   writeln('Converting ', data1.logno, data1.logty);
   data2.logno := data1.logno;
   data2.logty := data1.logty;
   data2.logda := data1.logda;
   data2.logmo := data1.logmo;
   data2.logyr := data1.logyr;
   data2.invno := data1.invno;
   data2.invda := data1.invda;
   data2.custn := data1.custn;
   data2.prod1 := data1.prod1;
   data2.prod2 := data1.prod2;
   data2.comp1 := data1.comp1;
   data2.comp2 := data1.comp2;
   data2.comp3 := '';
   data2.resp  := data1.resp;
   data2.cost  := data1.cost;
   data2.stats := data1.stats;
   data2.rtime := data1.rtime;
   data2.staff := data1.staff;
   data2.actpl := data1.actpl;
   write(file2, data2);
  end;

 close(file1);
 close(file2);
 writeln('Done converting, press a key...');
 readkey;
 writeln;
end.