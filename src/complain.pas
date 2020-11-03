{
  Programmer   : Lee Ting Zien
  Documentation: README.TXT/Printed on paper
  Language     : Turbo Pascal, Borland 7.0 compatible
  Ext Units    : None other than those provided with BTP7.0

  *** REFER TO README.TXT FOR MORE INFORMATION
}

program complaint_logging_system_YENOM;

uses crt, dos, windos;

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
  comp3: string[80];
  resp : string[40];    { responsibility }
  cost : real;          { cost impact }
  stats: boolean;       { status (open-1/closed-0) }
  rtime: integer;       { response time (days), -1 for NA }
  staff: string[64];    { sales person responsible }
  actpl: boolean;
 end;
 keyT = record
  lastinc: word;        { last autoincrement logno }
 end;
 securityT = record
  userid: string[14];
  passwd: string[14];
 end;

{ defination const }
const
 bgcolor = 1;           { background color - blue }
 fgcolor = 15;          { foreground color - white }
 alcolor = 12 + blink;  { alert color - red }
 brcolor = 14;          { border color }
 sbtext  = 0;           { status bar text color }
 sbbg    = 7;           { status bar background color }
 hbcolor = 7;           { hilight/typearea background - grey }
 hfcolor = 0;           { hilight/typearea text - black }
 datpath = '';          { data path }
 tmpcpat = 'TEMP';      { create temp path }
 logcpat = 'LOGS';      { create log path }
 bupcpat = 'BACKUP';    { create backup path }
 cfgcpat = 'CFG';       { config file path }
 keyfile = 'KEY.DAT';   { system key file name }
 secfile = 'SEC.DAT';   { security data file name }
 datfile = 'DATA.DA3';  { system data file name }
 confile = 'CONFIG.CFG';{ config file }
 version = '(v4.31c, DBv3+PerfM+EnUI2+EnRpt)';


{ internal const }
const
 validpasswd: set of '0'..'z' = ['0'..'9', 'A'..'Z', 'a'..'z', '_', '-'];
 tmppath = tmpcpat + '\';   { temp file path }
 buppath = bupcpat + '\';   { backup file path }
 cfgpath = cfgcpat + '\';   { config file path }
 logpath = logcpat + '\';   { log file path }

{ beep sound }
procedure beep;
 begin
  sound(1000);
  delay(50);
  nosound;
 end;

{ print center of screen, no CR }
procedure center(s: string);
 var x: byte;
 begin
   x := (80 - length(s)) div 2;
   gotoxy(x, wherey);
   write(s);
 end;

{ print center of screen, CR }
procedure centerln(s: string);
 begin
  center(s);
  writeln;
 end;

{ return OPEN/CLOSED string from boolean }
function returnstats(a: boolean): string;
 begin
  if a = true then returnstats := 'OPEN'
  else returnstats := 'CLOSED';
 end;

{ return DONE/NOT DONE string  from boolean }
function returnact(a: boolean): string;
 begin
  if a = true then returnact := 'DONE'
  else returnact := 'NOT DONE';
 end;

{ append zeros to number and output to str }
function appendzero(inc: word): string;
 var
   incs, incst: string;
   i: word;
 begin
  str(inc, incs);
  if length(incs) < 4 then { append zeros to increment value }
   begin
    incst := '';
    for i := 1 to 4 - length(incs) do
     incst := incst + '0';
    incs := incst + incs;
   end;
   appendzero := incs;
 end;

{ append spaces }
function appendspc(inc: word; s: string): string;
 var
   incst: string;
   i: word;
 begin
  if length(s) < inc then { append space to value }
   begin
    incst := s;
    for i := 1 to inc - length(s) do
     incst := incst + #32;
   end
  else incst := s;
   appendspc := incst;
 end;

{ truncate a string }
function truncs(c: word; s: string): string;
 var
  i : word;
  c1: word;
  ts: string;
 begin
  ts := '';

  if length(s) >= c then c1 := c
  else c1 := length(s);

  for i := 1 to c1 do
   ts := ts + s[i];

  truncs := ts;
 end;

{ upcase all chars of string }
function upper(s: string): string;
 var
   i: word;
   ts: string;
 begin
   ts := '';
   for i := 1 to length(s) do
     ts := ts + upcase(s[i]);
   upper := ts;
 end;

{ draw text input field }
procedure drawfield(l: word);
 var x, xl: word;
 begin
  x := wherex;
  textcolor(hfcolor);
  textbackground(hbcolor);
  for xl := wherex to wherex + l do
   begin
     gotoxy(xl, wherey);
     write(#32);
   end;
  gotoxy(x + 1, wherey)
 end;

{ reset screen colour to def }
procedure resetcolor;
 begin
  textbackground(bgcolor);
  textcolor(fgcolor);
 end;

{ bring cursor to lower end of screen }
procedure resetcursor;
 var x1, x2, y1, y2: byte;
 begin
  x1 := lo(windmin);    x2 := lo(windmax);
  y1 := hi(windmin);    y2 := hi(windmax);
  gotoxy(x2-x1, y2-y1);
 end;

{ get response time }
function getrtime(r: integer): string;
 var t: string;
 begin
  if r < 0 then getrtime := 'NA'
  else
   begin
    str(r, t);
    getrtime := t;
   end;
 end;

{ reset scr borders }
procedure setScr;
 var x, y: byte;
 begin
   clrscr;
   textmode(Font8x8 + CO80);
   window(1,1,80,50);
   textbackground(bgcolor);
   clrscr;

   { borders }
   textcolor(brcolor);

   { v205 h186 }
   for x := 2 to 79 do
    begin
     gotoxy(x, 1);
     write(#205);
     gotoxy(x, 49);
     write(#205);
     gotoxy(x, 7);
     write(#196);
     gotoxy(x, 48);
     write(#196);
    end;
   for y := 2 to 48 do
    begin
     gotoxy(1, y);
     write(#186);
     gotoxy(80, y);
     write(#186);
    end;
   gotoxy(1,1);
   write(#201);
   gotoxy(80,1);
   write(#187);
   gotoxy(1,49);
   write(#200);
   gotoxy(80,49);
   write(#188);

   gotoxy(1,7);
   write(#199);
   gotoxy(1,48);
   write(#199);

   gotoxy(80,7);
   write(#182);
   gotoxy(80,48);
   write(#182);

   textcolor(fgcolor);
 end;

{ print title }
procedure setTitle;
 begin
   gotoxy(1,3);
   centerln('Y E N O M   Q U A L I T Y   A S S U R A N C E   D E P A R T M E N T');
   gotoxy(1,5);
   centerln('PRODUCT COMPLAINT LOGGING AND REPORT SYSTEM');
   gotoxy(1,50);
   center('Copyright(c) 2000, Lee Ting Zien. ' + version);
   window(3,48,78,48);
   textbackground(sbbg);
   clrscr;
   textbackground(bgcolor);
   window(3,9,78,47);
   clrscr;
 end;

{ print status }
procedure status(s: string);
 var x, y: byte;
 begin
   { store current cords }
   x := wherex;
   y := wherey;

   { goto status window }
   window(4,48,77,48);
   textbackground(sbbg);
   textcolor(sbtext);

   { refresh and print }
   clrscr;
   write(s);

   { restore old window }
   textbackground(bgcolor);
   textcolor(fgcolor);
   window(3,9,78,47);

   { return cursor }
   gotoxy(x, y);
 end;

{ export for print }
procedure print(filename: string);
 var
   c: char;

 begin
   { prompt }
   writeln('Report generation is complete.');
   writeln;
   write('Do you want to launch your default RTF file viewer? (Y/N) ');

   { read for Y/N key }
   c := #0;
    while (upcase(c) <> 'Y') do
     begin
      c := upcase(readkey);
      if (c = 'N') or (c = #27) then
        begin
          writeln('N');
          writeln;
          writeln('You can use any software which supports RTF file format to open the file');
          writeln(filename, '. (e.g. WordPad, Microsoft Word)');
          writeln;
          writeln('Press a key...');
          status('Press a key to return to the previous screen...');
          readkey;
          exit;
        end
      else if c <> 'Y' then beep;
     end;
   writeln('Y');
   writeln;

   { pass to command prompt START "document.rtf" }
   status('Exporting to Windows for viewing...');
   swapvectors;
   exec(getenv('COMSPEC'), '/C START ' + filename);
   swapvectors;

   { capture dos kernel errors }
   if (doserror <> 0) and (doserror <> 5) then
     begin
       writeln('ERROR: Unable to export to wordpad! DOS Kernel Error #', doserror);
       writeln;
       writeln('Press a key...');
       status('An error has occurred while attempting to launch your viewer');
       readkey;
     end;

   { reset display }
   setScr;
   setTitle;
 end;

function getPasswd: boolean;
 var
   s: array[0..8] of char;
   sfp: file of securityT;
   sd: securityT;
   userid, passwd: string[14];
   check: boolean;
   e: char;
 begin
  filesearch(s, secfile, datpath);

  { capture missing file }
  if s[0] = #0 then
   begin
    status('Default security information file missing');
    writeln;
    writeln('System SECURITY file does not exist, creating...');
    writeln;
    assign(sfp, datpath + secfile);
    rewrite(sfp);
    writeln('Enter a primary UserID (14 chars MAX)');
    write('UserID: ');
    drawfield(16); readln(userid); resetcolor;
    writeln;
    writeln('Enter a password for ', userid, ' (14 chars MAX)');
    writeln('Passwords may only contain alphabets, numbers and dashes.');
    write('Passwd: ');
    drawfield(16); readln(passwd); resetcolor;
    writeln;
    write('Writing to security file and saving...');
    sd.userid := upper(userid);
    sd.passwd := passwd;
    write(sfp, sd);
    close(sfp);
    writeln('DONE');
    writeln;
    writeln('Press a key to begin...');
    readkey;
   end;

  { begin passwd input }
  clrscr;
  resetcolor;
  gotoxy(25,13);
  status('Enter your user name here');
  write('UserID: ');
  drawfield(16); readln(userid); resetcolor;
  gotoxy(33, 13);
  drawfield(16); writeln(upper(userid)); resetcolor;
  userid := upper(userid);
  gotoxy(25,16);
  status('Enter your password here');
  write('Passwd: ');
  drawfield(16);

  e := #0;
  passwd := '';
  while e <> #13 do
   begin
    e := readkey;
    if e <> #13 then begin
     if e in validpasswd then
      begin
       passwd := passwd + e;
       write('*');
      end
     else beep;
    end;
   end;

  { begin passwd matching }
  check := false;

  { open file }
  assign(sfp, datpath + secfile);
  reset(sfp);

  { match passwd entries }
  while (eof(sfp) = false) and (check = false) do
   begin
     read(sfp, sd);
     if (sd.userid = userid) and (sd.passwd = passwd) then
       check := true;
   end;

  { close file }
  close(sfp);

  { reset screen color }
  resetcolor;

  if check = false then { return ERROR }
   begin
    writeln;
    writeln;
    writeln;
    writeln;
    textcolor(alcolor);
    centerln('Password error!');
    writeln;
    resetcolor;
    centerln('Press a key...');
    resetcursor;
    readkey;
    getPasswd := false;
   end
  else { return OK }
    getPasswd := true;

 end;

function showMenu(selected: byte): byte;
 var
  select: byte;
  input : char;

 begin
  select := selected;
  input := #0;

  while input <> #13 do
   begin
    textbackground(bgcolor);
    textcolor(fgcolor);
    clrscr;

    centerln('MAIN MENU');
    writeln;
    centerln('Select your choice...');
    writeln;

    if select = 1 then begin
     status('Adds a complaint record to the database');
     textcolor(0);
     textbackground(7);
    end else begin
     textcolor(fgcolor);
     textbackground(bgcolor);
    end;
     centerln(' Enter a new complaint record     ');

    if select = 2 then begin
     status('Edits complaint records to the database');
     textcolor(0);
     textbackground(7);
    end else begin
     textcolor(fgcolor);
     textbackground(bgcolor);
    end;
    centerln(' Modify/update a complaint record ');

    if select = 3 then begin
     status('Browse through the complaint records in the database');
     textcolor(0);
     textbackground(7);
    end else begin
     textcolor(fgcolor);
     textbackground(bgcolor);
    end;
    centerln(' View complaint record(s)         ');

    if select = 4 then begin
     status('Remove a complaint record from the database');
     textcolor(0);
     textbackground(7);
    end else begin
     textcolor(fgcolor);
     textbackground(bgcolor);
    end;
    centerln(' Delete a complaint record        ');

    if select = 5 then begin
     status('Create a report for printing/anaylsing');
     textcolor(0);
     textbackground(7);
    end else begin
     textcolor(fgcolor);
     textbackground(bgcolor);
    end;
    centerln(' Export a monthly report          ');


    if select = 6 then begin
     status('Exit this program');
     textcolor(0);
     textbackground(7);
    end else begin
     textcolor(fgcolor);
     textbackground(bgcolor);
    end;
    centerln(' Quit this program                ');

    resetcursor;

    input := readkey;
    if input = #0 then
     begin
       input := readkey;
       if input = #80 then
        begin
         if select < 6 then select := select + 1
         else select := 1;
        end
       else if input = #72 then
        begin
         if select > 1 then select := select - 1
         else select := 6;
        end;
     end
    else if input = #27 then
     begin
      select := 6;
      input := #13; { break the loop }
     end;

   end;

   showMenu := select;
 end;

procedure showMenu_ADD;
 var
  datfp, datfp2: file of complaintT;
  dat, dat2: complaintT;
  keyfp: file of keyT;
  keyd: keyT;
  y, m, d, dow: word;
  c, c1: char;
  s: array[0..8] of char;
  invno: string[20];
  invdaok: boolean;

 begin
  clrscr;
  centerln('ENTER A NEW COMPLAINT RECORD');
  writeln;

  { autogenerate key file if not exist }
  filesearch(s, keyfile, datpath);
  if s[0] = #0 then
   begin
    assign(keyfp, datpath + keyfile);
    rewrite(keyfp);
    keyd.lastinc := 0;
    write(keyfp, keyd);
    close(keyfp);
   end;

  { start }
  textcolor(fgcolor);
  textbackground(bgcolor);
  c := #0;
  c1 := #0;
  while (upcase(c1) <> 'N') do
   begin
    clrscr;
    centerln('ENTER A NEW COMPLAINT RECORD');
    writeln;
    status('''Y'' proceeds with entering a new record, ''N'' exits this screen.');
    write('Enter a new record? (Y/N) ');
    c1 := #0;
    while (upcase(c1) <> 'Y') do
     begin
      c1 := upcase(readkey);
      if (c1 = 'N') or (c1 = #27) then exit
      else if c1 <> 'Y' then beep;
     end;

    { keyfile increment }
    assign(keyfp, datpath + keyfile);
    reset(keyfp);
    read(keyfp, keyd);
    close(keyfp);
    keyd.lastinc := keyd.lastinc + 1;

    writeln(c1);
    writeln;
    status('Hit ''L'' for a local log type and ''E'' for a overseas export log type.');
    write('Log Type ("L"ocal/"E"xport): ');
    c := #0;
    while (c <> 'L') and (c <> 'E') do
     begin
      c := readkey;
      c := upcase(c);
      if (c <> 'L') and (c <> 'E') then beep;
     end;

    gotoxy(40,wherey);
    write('Log #: ');
    drawfield(17);

    getdate(y, m, d, dow);
    write('C', appendzero(keyd.lastinc), c, '/', d, '/', m, '/', y);
    resetcolor;

    writeln;
    writeln;
    writeln;

    invno := '123456789';

    status('Enter the invoice number of the relevant product here');
    while length(invno) > 8 do
     begin
      gotoxy(1, wherey-1);
      write('Invoice No. (8 chars MAX) ');
      drawfield(15); readln(invno); resetcolor;
      if length(invno) > 8 then beep;
     end;

    gotoxy(27, wherey - 1); drawfield(15); writeln(upper(invno));
    resetcolor;

    writeln;
    writeln;

    invdaok := false;

    while invdaok = false do
     begin
      gotoxy(1, wherey-1);
      write('Invoice Date (DD/MM/YYYY) ');
      drawfield(15); readln(dat.invda); resetcolor;

      if (dat.invda[3] <> '/') or (dat.invda[6] <> '/') then
       begin
        beep;
        invdaok := false;
       end
      else if (length(dat.invda) > 10) then
       begin
        beep;
        invdaok := false;
       end
      else invdaok := true;
     end;

    writeln;

    write('Customer Name ');
    drawfield(59); readln(dat.custn); resetcolor;
    dat.custn := upper(dat.custn);
    gotoxy(15, wherey - 1); drawfield(59); writeln(dat.custn); resetcolor;

    writeln;

    write('Sales Staff   ');
    drawfield(59); readln(dat.staff); resetcolor;
    dat.staff := upper(dat.staff);
    gotoxy(15, wherey - 1); drawfield(59); writeln(dat.staff); resetcolor;

    writeln;

    writeln('Defective Product(s)');
    writeln;

    write(' a. '); drawfield(69); readln(dat.prod1); resetcolor;
    dat.prod1 := upper(dat.prod1);
    gotoxy(5, wherey - 1); drawfield(69); writeln(dat.prod1); resetcolor;
    write(' b. '); drawfield(69); readln(dat.prod2); resetcolor;
    dat.prod2 := upper(dat.prod2);
    gotoxy(5, wherey - 1); drawfield(69); writeln(dat.prod2); resetcolor;
    writeln;
    writeln;

    writeln('Nature of Complaint ');
    writeln;

    write(' a. '); drawfield(69); readln(dat.comp1); resetcolor;
    dat.comp1 := upper(dat.comp1);
    gotoxy(5, wherey - 1); drawfield(69); writeln(dat.comp1); resetcolor;
    write(' b. '); drawfield(69); readln(dat.comp2); resetcolor;
    dat.comp2 := upper(dat.comp2);
    gotoxy(5, wherey - 1); drawfield(69); writeln(dat.comp2); resetcolor;
    write(' c. '); drawfield(69); readln(dat.comp3); resetcolor;
    dat.comp3 := upper(dat.comp3);
    gotoxy(5, wherey - 1); drawfield(69); writeln(dat.comp3); resetcolor;

    writeln;
    writeln;

    { set all vars to record }
    dat.logty := c;
    dat.logno := keyd.lastinc;
    dat.logda := d;
    dat.logmo := m;
    dat.logyr := y;
    dat.invno := upper(invno);

    dat.resp  := 'UNKNOWN'; { responsibility set blank }
    dat.cost  := 0.00; { cost impact set S$0.00 }
    dat.stats := true; { status set open }
    dat.rtime := 0; { response time set -1 }
    dat.actpl := false;

    filesearch(s, datfile, datpath);

    { file dosen't exist, create }
    if s[0] = #0 then
     begin
      status('Creating database and adding record...');
      assign(datfp, datpath + datfile);
      rewrite(datfp);
      write(datfp, dat);
      close(datfp);
     end
    else { exist }
     begin
      status('Adding record, please wait (swapping)...');
      assign(datfp, datpath + datfile);
      assign(datfp2, tmppath + 'DATA.TMP');
      reset(datfp);
      rewrite(datfp2);
      while not eof(datfp) do
       begin
        read(datfp, dat2);
        write(datfp2, dat2); { write to tmp }
       end;

      status('Adding record, please wait (rewriting)...');
      rewrite(datfp);
      reset(datfp2);
      while not eof(datfp2) do
       begin
        read(datfp2, dat2); { read from tmp }
        write(datfp, dat2); { write to original }
       end;

      close(datfp2);
      write(datfp, dat);
      close(datfp);
     end;

    { write increment key }
    assign(keyfp, datpath + keyfile);
    rewrite(keyfp);
    write(keyfp, keyd);
    close(keyfp);

    resetcolor;
   end;
 end;

procedure showMenu_EDIT(entry: integer);
 var
  datfp, datfp2: file of complaintT;
  dat, dat2: complaintT;
  c: char;
  e: byte;
  recno: longint;
  recfound: boolean;
  s: array[0..8] of char;

 begin
  textcolor(fgcolor);
  textbackground(bgcolor);
  while (1 = 1) do
   begin
    clrscr;
    centerln('MODIFY/UPDATE A COMPLAINT RECORD');
    writeln;

    filesearch(s, datfile, datpath);

    if s[0] = #0 then
     begin
      status('Database file does not exist. Please add a record to create it.');
      textcolor(alcolor);
      writeln('ERROR: Data file "' + datfile + '" dose not exist!');
      resetcolor;
      writeln;
      writeln('You cannot use this feature until you have created a data file');
      writeln('by adding a complaint record!');
      writeln;
      writeln('This session will terminate. Press a key...');
      readkey;
      exit;
     end;

    if entry < 0 then
      begin
       status('Enter the complaint log number for editing');
       write('Log Number to edit: (1-9999), 0 to exit) ');
       drawfield(6); readln(recno); resetcolor;
       writeln;
      end
    else recno := entry;

    status('Searching for record C' + appendzero(recno) + '...');

    if recno <= 0 then exit;
    recfound := false;

    assign(datfp, datpath + datfile);
    reset(datfp);

    while (eof(datfp) = false) and (recfound = false) do
     begin
       read(datfp, dat);
       if dat.logno = recno then
        recfound := true;
     end;

    close(datfp);

    if recfound = false then
     begin
      beep;
      status('ERROR: Record not found. Please try again.');
      writeln('Cannot find record. Please try again.');
      writeln;
      writeln('Press a key...');
      readkey;
      continue;
     end;

    e := 1;

    while (e <> 0) do
     begin
      clrscr;
      status('Listing record contents...');
      centerln('MODIFY/UPDATE A COMPLAINT RECORD');
      writeln;
      gotoxy(45,wherey);
      write(' Record No. ');
      drawfield(17);
      with dat do
       writeln('C', appendzero(logno), logty, '/', logda, '/', logmo, '/', logyr);
      resetcolor;

      writeln;
      write('  1. Invoice No.   ');
      drawfield(15); writeln(dat.invno); resetcolor;

      writeln;
      write('  2. Invoice Date  ');
      drawfield(15); writeln(dat.invda); resetcolor;

      writeln;
      write('  3. Customer Name ');
      drawfield(54); writeln(truncs(52, dat.custn)); resetcolor;

      writeln;
      write('  4. Sales Staff   ');
      drawfield(54); writeln(truncs(52, dat.staff)); resetcolor;


      writeln;
      writeln('  5. Defective Product(s)');
      write('     a. '); drawfield(65); writeln(truncs(63,dat.prod1)); resetcolor;
      write('     b. '); drawfield(65); writeln(truncs(63,dat.prod2)); resetcolor;

      writeln;
      writeln('  6. Nature of Complaint');
      write('     a. '); drawfield(65); writeln(truncs(63,dat.comp1)); resetcolor;
      write('     b. '); drawfield(65); writeln(truncs(63,dat.comp2)); resetcolor;
      write('     c. '); drawfield(65); writeln(truncs(63,dat.comp3)); resetcolor;

      writeln;
      write('  7. Resposibility ');
      drawfield(20); writeln(dat.resp); resetcolor;

      writeln;
      write('  8. Cost Impact   ');
      drawfield(20); writeln('S$', dat.cost:0:2); resetcolor;

      writeln;
      write('  9. Status        ');
      drawfield(10); writeln(returnstats(dat.stats)); resetcolor;

      writeln;
      write(' 10. Response Time ');
      drawfield(10);
      if dat.rtime <= 0 then
       writeln('N/A')
      else
       writeln(dat.rtime, ' days');
      resetcolor;

      writeln;
      write(' 11. Action Plan   ');
      drawfield(10); writeln(returnact(dat.actpl)); resetcolor;

      writeln;
      writeln;
      status('Enter the number of the record field you would like to edit');
      write('Edit which field? (1-11, 0 exits) ');
      readln(e);
      writeln;

      if e = 1 then
       begin
        status('Enter a new invoice number for the record');
        gotoxy(20, 5);
        drawfield(15); readln(dat.invno); resetcolor;

        while (1=1) do
         begin
          if length(dat.invno) <= 8 then break;
          gotoxy(20, wherey - 1);
          beep;
          drawfield(15); readln(dat.invno); resetcolor;
         end;

        dat.invno := upper(dat.invno);
        gotoxy(20, wherey - 1);
        drawfield(15); writeln(dat.invno); resetcolor;
       end
      else if e = 2 then
       begin
        status('Enter a new invoice date for the record');
        gotoxy(20, 7);
        drawfield(15); readln(dat.invda); resetcolor;
        dat.invda := upper(dat.invda);
       end
      else if e = 3 then
       begin
        status('Enter a new customer name. Tip: Keep names within 30 characters.');
        gotoxy(20, 9);
        drawfield(54); readln(dat.custn); resetcolor;
        dat.custn := upper(dat.custn);
       end
      else if e = 4 then
       begin
        status('Enter a new name for the responsible sales staff then hit ENTER.');
        gotoxy(20, 11);
        drawfield(54); readln(dat.staff); resetcolor;
        dat.staff := upper(dat.staff);
       end
      else if e = 5 then
       begin
        status('Enter a new product name. Tip: Keep line within 30 characters.');
        gotoxy(9, 14);
        drawfield(65); readln(dat.prod1); resetcolor;
        gotoxy(9, 15);
        drawfield(65); readln(dat.prod2); resetcolor;
        dat.prod1 := upper(dat.prod1);
        dat.prod2 := upper(dat.prod2);
       end
      else if e = 6 then
       begin
        status('Enter a new complaint nature. Tip: Keep line within 30 characters.');
        gotoxy(9, 18);
        drawfield(65); readln(dat.comp1); resetcolor;
        gotoxy(9, 19);
        drawfield(65); readln(dat.comp2); resetcolor;
        gotoxy(9, 20);
        drawfield(65); readln(dat.comp3); resetcolor;
        dat.comp1 := upper(dat.comp1);
        dat.comp2 := upper(dat.comp2);
        dat.comp3 := upper(dat.comp3);
       end
      else if e = 7 then
       begin
        status('Enter the name of the responsible party of cause of complaint');
        gotoxy(20, 22);
        drawfield(20); readln(dat.resp); resetcolor;
        dat.resp := upper(dat.resp);
       end
      else if e = 8 then
       begin
        status('Enter new value for cost impact. Do not use "," digit seperators.');
        gotoxy(20, 24);
        drawfield(20); readln(dat.cost); resetcolor;
       end
      else if e = 9 then
       begin
        status('Hit 1 to change status to Open, hit 0 to change status to Closed.');
        gotoxy(20, 25);
        drawfield(10);
        c := #0;
        while (c <> '0') and (c <> '1') do
         begin
          c := readkey;
          c := upcase(c);
          if (c = '0') or (c = 'C') then
           begin
            c := '0';
            dat.stats := false;
           end
          else if (c = '1') or (c = 'O') then
           begin
            c := '1';
            dat.stats := true;
           end
          else beep;
         end;
        resetcolor;
       end
      else if e = 10 then
       begin
        status('Enter a new response time (in no. of days)');
        gotoxy(20, 28);
        drawfield(10); readln(dat.rtime); resetcolor;
       end
      else if e = 11 then
       begin
        status('Hit 1 or D to change to Done, hit 0 or N to change status to Not Done.');
        gotoxy(20, 30);
        drawfield(10);
        c := #0;
        while (c <> '0') and (c <> '1') do
         begin
          c := readkey;
          c := upcase(c);
          if (c = '0') or (c = 'N') then
           begin
            c := '0';
            dat.actpl := false;
           end
          else if (c = '1') or (c = 'D') then
           begin
            c := '1';
            dat.actpl := true;
           end
          else beep;
         end;
        resetcolor;
       end
      else if e <> 0 then beep;


      { disk buffer append method }

      { duplicate current data to temp file }
      if e = 0 then { update only when exit - perfM module }
       begin
        status('Updating record C' + appendzero(dat.logno) + ', please wait (swapping)...');
        assign(datfp, datpath + datfile);
        assign(datfp2, tmppath + 'DATA.TMP');
        reset(datfp);
        rewrite(datfp2);
        while not eof(datfp) do
         begin
           read(datfp, dat2);
           write(datfp2, dat2); { write to tmp }
         end;

        { rewrite database }
        status('Updating record C' + appendzero(dat.logno) + ', please wait (rewriting)...');
        rewrite(datfp);
        reset(datfp2);
        while not eof(datfp2) do
         begin
           read(datfp2, dat2); { read from tmp }
           if dat2.logno = dat.logno then write(datfp, dat)
           else write(datfp, dat2); { write to original }
         end;

        close(datfp2);
        close(datfp);
       end;

    end;
    if entry >= 0 then exit;
   end;
 end;

procedure showMenu_DEL(entry: integer);
 var
  datfp, datfp2: file of complaintT;
  dat, dat2: complaintT;
  e: char;
  recno: longint;
  recfound: boolean;
  s: array[0..8] of char;

 begin
  textcolor(fgcolor);
  textbackground(bgcolor);
  filesearch(s, datfile, datpath);

  if s[0] = #0 then
   begin
    clrscr;
    centerln('DELETE A COMPLAINT RECORD');
    writeln;
    status('Database file does not exist. Please add a record to create it.');
    textcolor(alcolor);
    writeln('ERROR: Data file "' + datfile + '" dose not exist!');
    resetcolor;
    writeln;
    writeln('You cannot use this feature until you have created a data file');
    writeln('by adding a complaint record!');
    writeln;
    writeln('This session will terminate. Press a key...');
    readkey;
    exit;
   end;

  while (1 = 1) do
   begin
    clrscr;
    centerln('DELETE A COMPLAINT RECORD');
    writeln;

    if entry < 0 then
      begin
       status('Enter the complaint log number for deleting');
       write('Log Number to delete: (1-9999), 0 to exit) ');
       drawfield(6); readln(recno); resetcolor;
       writeln;
      end
    else recno := entry;

    status('Searching for record C' + appendzero(recno) + '...');

    if recno <= 0 then exit;

    recfound := false;

    assign(datfp, datpath + datfile);
    reset(datfp);

    while (eof(datfp) = false) and (recfound = false) do
     begin
      read(datfp, dat);
      if dat.logno = recno then
       recfound := true;
     end;

    close(datfp);

    if recfound = false then
     begin
      beep;
      status('ERROR: Record not found. Please try again.');
      writeln('Cannot find record. Please try again.');
      writeln;
      writeln('Press a key...');
      readkey;
      continue;
     end
    else
     begin
      clrscr;
      status('Listing record contents...');
      centerln('DELETE A COMPLAINT RECORD');
      writeln;
      gotoxy(45,wherey);
      write(' Record No. ');
      drawfield(17);
      with dat do
       writeln('C', appendzero(logno), logty, '/', logda, '/', logmo, '/', logyr);
      resetcolor;

      writeln;
      write('  Invoice No.   ');
      drawfield(15); writeln(dat.invno); resetcolor;

      writeln;
      write('  Invoice Date  ');
      drawfield(15); writeln(dat.invda); resetcolor;

      writeln;
      write('  Customer Name ');
      drawfield(57); writeln(truncs(55, dat.custn)); resetcolor;

      writeln;
      write('  Sales Staff   ');
      drawfield(57); writeln(truncs(55, dat.staff)); resetcolor;


      writeln;
      writeln('  Defective Product(s)');
      write('     a. '); drawfield(65); writeln(truncs(63,dat.prod1)); resetcolor;
      write('     b. '); drawfield(65); writeln(truncs(63,dat.prod2)); resetcolor;

      writeln;
      writeln('  Nature of Complaint');
      write('     a. '); drawfield(65); writeln(truncs(63,dat.comp1)); resetcolor;
      write('     b. '); drawfield(65); writeln(truncs(63,dat.comp2)); resetcolor;
      write('     c. '); drawfield(65); writeln(truncs(63,dat.comp3)); resetcolor;

      writeln;
      write('  Resposibility ');
      drawfield(20); writeln(dat.resp); resetcolor;

      writeln;
      write('  Cost Impact   ');
      drawfield(20); writeln('S$', dat.cost:0:2); resetcolor;

      writeln;
      write('  Status        ');
      drawfield(10); writeln(returnstats(dat.stats)); resetcolor;

      writeln;
      write('  Response Time ');
      drawfield(10);
      if dat.rtime <= 0 then
       writeln('N/A')
      else
       writeln(dat.rtime, ' days');
      resetcolor;

      writeln;
      write('  Action Plan   ');
      drawfield(10); writeln(returnact(dat.actpl)); resetcolor;

      writeln;
      writeln;
      status('Answer "Y" to delete this record, "N" to keep record intact.');
      write('Delete? (Y/N) ');
      readln(e);
      e := upcase(e);

      if e = 'Y' then
       begin
        status('Deleting record C' + appendzero(dat.logno) + ', please wait (swapping)...');

        assign(datfp, datpath + datfile);
        assign(datfp2, tmppath + 'DATA.TMP');
        reset(datfp);
        rewrite(datfp2);
        while not eof(datfp) do
         begin
          read(datfp, dat2);
          write(datfp2, dat2); { write to tmp }
         end;
        status('Deleting record C' + appendzero(dat.logno) + ', please wait (rewriting)...');
        rewrite(datfp);
        reset(datfp2);
        while not eof(datfp2) do
         begin
          read(datfp2, dat2); { read from tmp }
          if dat2.logno <> dat.logno then write(datfp, dat2); { write to original }
         end;

        close(datfp2);
        close(datfp);

        status('Record has been deleted. Press a key to proceed.');
        writeln;
        writeln('Press a key...');
        readkey;
       end;
       if entry >= 0 then exit;
     end;
  end;
 end;


procedure showMenu_PRINT;
 const
   linesperpage = 13;

 var fp: file of complaintT;
     dat, dat1, dat2: complaintT;
     outfp, logfp: text;
     s: array[0..1] of char;
     sel: integer;
     scroll: byte;
     d, m, y, dow: word;
     h, mn, ss, ms: word;
     bc: char;
     show: boolean;
     outtxt: string;
     avgcost: real;
     copen, cclosed, totlist, page: word;
     line: byte;
 begin
   clrscr;
   centerln('EXPORT A MONTHLY REPORT');
   writeln;

   filesearch(s, datfile, datpath);

   if s[0] = #0 then
    begin
     status('Database file does not exist. Please add a record to create it.');
     textcolor(alcolor);
     writeln('ERROR: Data file "' + datfile + '" dose not exist!');
     resetcolor;
     writeln;
     writeln('You cannot use this feature until you have created a data file');
     writeln('by adding a complaint record!');
     writeln;
     writeln('This session will terminate. Press a key...');
     readkey;
     exit;
    end;

   status('Select the criteria in which you want your report to be listed');

   sel := 1;
   bc  := #0;
   while (bc <> #13) do
    begin
     resetcolor;
     clrscr;
     centerln('EXPORT A MONTHLY REPORT');
     writeln;
     centerln('What filtering criteria do you want to use on your report?');
     writeln;

     resetcolor;
     centerln('ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ');


     if sel = 1 then begin
      status('Your report will be filtered by a log number range');
      textcolor(0);
      textbackground(7);
     end else begin
      textcolor(fgcolor);
      textbackground(bgcolor);
     end;
     centerln(' Log Number        <F3> ');

     if sel = 2 then begin
      status('Your report will be filtered by a log date range');
      textcolor(0);
      textbackground(7);
     end else begin
      textcolor(fgcolor);
      textbackground(bgcolor);
     end;
     centerln(' Log Date          <F4> ');

     if sel = 3 then begin
      status('Your report will be filtered by log type');
      textcolor(0);
      textbackground(7);
     end else begin
      textcolor(fgcolor);
      textbackground(bgcolor);
     end;
     centerln(' Log Type          <F5> ');

     resetcolor;
     centerln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

     if sel = 4 then begin
      status('Your report will be filtered by matching the responsibility');
      textcolor(0);
      textbackground(7);
     end else begin
      textcolor(fgcolor);
      textbackground(bgcolor);
     end;
     centerln(' Responsibility    <F6> ');

     resetcolor;
     centerln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

     if sel = 5 then begin
      status('Your report will be filtered by a cost impact range');
      textcolor(0);
      textbackground(7);
     end else begin
      textcolor(fgcolor);
      textbackground(bgcolor);
     end;
     centerln(' Cost Impact       <F7> ');

     resetcolor;
     centerln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

     if sel = 6 then begin
      status('Your report will be filtered by the status of the complaint');
      textcolor(0);
      textbackground(7);
     end else begin
      textcolor(fgcolor);
      textbackground(bgcolor);
     end;
     centerln(' Complaint Status  <F8> ');

     resetcolor;
     centerln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

     if sel = 7 then begin
      status('Your report will be filtered by a response time range');
      textcolor(0);
      textbackground(7);
     end else begin
      textcolor(fgcolor);
      textbackground(bgcolor);
     end;
     centerln(' Response Time     <F9> ');

     resetcolor;
     centerln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

     if sel = 8 then begin
      status('Your report will not be filtered - All entries will be listed');
      textcolor(0);
      textbackground(7);
     end else begin
      textcolor(fgcolor);
      textbackground(bgcolor);
     end;
     centerln(' No Filtering     <F10> ');

     resetcolor;
     centerln('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');

     if sel = 0 then begin
      status('Exit this screen');
      textcolor(0);
      textbackground(7);
     end else begin
      textcolor(fgcolor);
      textbackground(bgcolor);
     end;
     centerln(' Exit             <ESC> ');

     resetcolor;
     centerln('ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ');

     bc := readkey;
     if bc = #0 then
      begin
        bc := readkey;
        if bc = #80 then
         begin
          if sel < 8 then sel := sel + 1
          else sel := 0;
         end
        else if bc = #72 then
         begin
          if sel > 0 then sel := sel - 1
          else sel := 8;
         end
        else if (ord(bc) >= 61) and (ord(bc) <= 68) then
         begin
          sel := ord(bc) - 60;
         end;
      end
     else if bc = #27 then sel := 0
    end;


   { add one line crlf }
   writeln;

   { get input }
   if sel = 1 then { log no }
    begin
      writeln('Log number range');
      status('Enter the starting number of the log you want to be listed');
      write('  From:');
      drawfield(6); readln(dat1.logno); resetcolor;
      status('Enter the ending number of the log you want to be listed');
      write('  To  :');
      drawfield(6); readln(dat2.logno); resetcolor;
    end
   else if sel = 2 then { log date }
    begin
      writeln('Log Date Range');
      status('Enter the starting day of the range to be listed');
      write('  From DD  :');
      drawfield(3); readln(dat1.logda); resetcolor;
      status('Enter the starting month of the range to be listed');
      write('  From MM  :');
      drawfield(3); readln(dat1.logmo); resetcolor;
      status('Enter the starting year of the range to be listed');
      write('  From YYYY:');
      drawfield(5); readln(dat1.logyr); resetcolor;
      writeln;
      status('Enter the ending day of the range to be listed');
      write('  To DD  : ');
      drawfield(3); readln(dat2.logda); resetcolor;
      status('Enter the ending month of the range to be listed');
      write('  To MM  : ');
      drawfield(3); readln(dat2.logmo); resetcolor;
      status('Enter the ending year of the range to be listed');
      write('  To YYYY: ');
      drawfield(5); readln(dat2.logyr); resetcolor;
    end
   else if sel = 3 then { type }
    begin
      status('Enter the log type to be listed in your report');
      write('Log type (L=Local, E=Export): ');
      drawfield(2); readln(dat1.logty); resetcolor;
      dat1.logty := upcase(dat1.logty);
      gotoxy(31, wherey-1); drawfield(20); writeln(dat1.logty);
      resetcolor;
    end
   else if sel = 4 then { resp }
    begin
      status('Enter the EXACT PHRASE of the responsible party causing the complaint');
      write('Responsibility: ');
      drawfield(20); readln(dat1.resp); resetcolor;
      dat1.resp := upper(dat1.resp);
      gotoxy(16, wherey-1); drawfield(20); writeln(dat1.resp);
      resetcolor;
    end
   else if sel = 5 then { cost }
    begin
      writeln('Cost Impact Range');
      status('Enter the starting cost impact value to generate your report from');
      write('  From S$');
      drawfield(20); readln(dat1.cost); resetcolor;
      status('Enter the ending cost impact value to generate your report from');
      write('  To   S$');
      drawfield(20); readln(dat2.cost); resetcolor;
    end
   else if sel = 6 then { stats }
    begin
      status('Enter 1 for Open status, and 0 for Closed status.');
      write('Status (1=Open, 0=Closed): ');
      drawfield(2); readln(bc); resetcolor;
      if bc = '0' then dat1.stats := false
      else if bc = '1' then dat1.stats := true
      else beep;
    end
   else if sel = 7 then { rtime }
    begin
      writeln('Response Time Range');
      status('Enter the starting responsible time range to be listed');
      write('  From (days): ');
      drawfield(10); readln(dat1.rtime); resetcolor;
      status('Enter the ending responsible time range to be listed');
      write('  To   (days): ');
      drawfield(10); readln(dat2.rtime); resetcolor;
    end
   else if sel = 0 then exit;

   { obtain date/time }
   getdate(y, m, d, dow);
   gettime(h, mn, ss, ms);

   { open log file }
   assign(logfp, logpath + 'REPORT.LOG');
   rewrite(logfp);
   writeln;
   writeln('Report generation log REPORT.LOG, generated ', d, '/', m, '/', y, ' ', h, ':', mn, ':', ss, '.');
   writeln;
   writeln(logfp, '[',d,'/',m,'/',y,' ',h,':',mn,':',ss,'] Logging started...');

   writeln(logfp, '[',d,'/',m,'/',y,' ',h,':',mn,':',ss,'] Preparing report generation...');
   for scroll := 1 to 5 do
    begin
     status('Preparing to generate report.');
     delay(20);
     status('Preparing to generate report..');
     delay(20);
     status('Preparing to generate report...');
     delay(20);
     status('Preparing to generate report....');
     delay(20);
     status('Preparing to generate report.....');
     delay(20);
    end;

   { database open readonly }
   assign(fp, datpath + datfile);
   reset(fp);

   { temp prn output }
   randomize;
   outtxt := tmppath + '$' + appendzero(random(9999)) + '.RTF';
   assign(outfp, outtxt);
   rewrite(outfp);

   { headers }
   writeln(logfp, '[',d,'/',m,'/',y,' ',h,':',mn,':',ss,'] Writing report headers...');
   status('Generating report headers...');

   write  (outfp, '{\rtf1\ansi\ansicpg1252\uc1 \deff0\deflang1033\deflangfe1033');
   write  (outfp, '{\fonttbl{\f0\froman\fcharset0\fprq2{\*\panose 02020603050405020304}Times New Roman;}');
   writeln(outfp, '{\f2\fmodern\fcharset0\fprq1{\*\panose 02070309020205020404}Courier New;}');
   write  (outfp, '{\f29\froman\fcharset238\fprq2 Times New Roman CE;}{\f30\froman\fcharset204\fprq2 Times New Roman Cyr;}');
   write  (outfp, '{\f32\froman\fcharset161\fprq2 Times New Roman Greek;}{\f33\froman\fcharset162\fprq2');
   writeln(outfp, ' Times New Roman Tur;}');
   write  (outfp, '{\f34\froman\fcharset186\fprq2 Times New Roman Baltic;}{\f41\fmodern\fcharset238\fprq1 Courier New CE;}');
   write  (outfp, '{\f42\fmodern\fcharset204\fprq1 Courier New Cyr;}{\f44\fmodern\fcharset161\fprq1 Courier New Greek;}');
   writeln(outfp, '{\f45\fmodern\fcharset162\fprq1 Courier New Tur;}');
   write  (outfp, '{\f46\fmodern\fcharset186\fprq1 Courier New Baltic;}}{\colortbl;\red0\green0\blue0;\red0\green0\blue255;');
   write  (outfp, '\red0\green255\blue255;\red0\green255\blue0;\red255\green0\blue255;\red255\green0\blue0;');
   writeln(outfp, '\red255\green255\blue0;\red255\green255\blue255;');
   write  (outfp, '\red0\green0\blue128;\red0\green128\blue128;\red0\green128\blue0;\red128\green0\blue128;');
   writeln(outfp, '\red128\green0\blue0\red128\green128\blue0;\red128\green128\blue128;\red192\green192\blue192;}');
   writeln(outfp, '{\stylesheet{\widctlpar\adjustright \fs20\cgrid \snext0 Normal;}{\*');
   write  (outfp, '\cs10 \additive Default Paragraph Font;}}{\info{\author User}{\operator User}');
   write  (outfp, '{\creatim\yr2000\mo2\dy9\hr16\min59}');
   write  (outfp, '{\revtim\yr2000\mo2\dy9\hr17}{\version3}{\edmins0}{\nofpages1}{\nofwords0}{\nofchars0}');
   writeln(outfp, '{\*\company Yenom Label Materials (S) Pte Ltd}');
   write  (outfp, '{\nofcharsws0}{\vern89}}\paperw16834\paperh11909\margl720\margr720\margt720\margb720 ');
   write  (outfp, '\widowctrl\ftnbj\aenddoc\hyphcaps0\formshade\viewkind1\viewscale65\viewzk2\pgbrdrhead\pgbrdrfoot ');
   writeln(outfp, '\fet0\sectd \lndscpsxn\psz9\linex0\endnhere\sectdefaultcl {\*\pnseclvl1');
   write  (outfp, '\pnucrm\pnstart1\pnindent720\pnhang{\pntxta .}}{\*\pnseclvl2\pnucltr\pnstart1\pnindent720\pnhang');
   write  (outfp, '{\pntxta .}}{\*\pnseclvl3\pndec\pnstart1\pnindent720\pnhang{\pntxta .}}');
   writeln(outfp, '{\*\pnseclvl4\pnlcltr\pnstart1\pnindent720\pnhang{\pntxta )}}{\*\pnseclvl5');
   write  (outfp, '\pndec\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta )}}');
   write  (outfp, '{\*\pnseclvl6\pnlcltr\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta )}}');
   write  (outfp, '{\*\pnseclvl7\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb (}{\pntxta )}}');
   writeln(outfp, '{\*\pnseclvl8\pnlcltr\pnstart1\pnindent720\pnhang');
   write  (outfp, '{\pntxtb (}{\pntxta )}}{\*\pnseclvl9\pnlcrm\pnstart1\pnindent720\pnhang{\pntxtb (}');
   writeln(outfp, '{\pntxta )}}\pard\plain \widctlpar\adjustright \fs20\cgrid {\f2\fs14');
   writeln(outfp, '\par');

   writeln(outfp, '\par YENOM LABEL MATERIALS (S) PTE LTD/QA COMPLAINT REPORT');
   writeln(outfp, '\par');
   writeln(outfp, '\par Date generated: ', d, '/', m, '/', y, ' ', h, ':', mn, ':', ss);
   writeln(outfp, '\par');
   writeln(outfp);

   writeln(logfp, '[',d,'/',m,'/',y,' ',h,':',mn,':',ss,'] Writing data table...');
   write(outfp, '\par ========================================================================================');
   writeln(outfp, '=======================================================================================');
   write(outfp, '\par | Log No.    | Invoice    | Customer/Responsibility        |');
   write(outfp, ' Defective Product         | Nature of Complaint                 | Cost Impact/S$  ');
   writeln(outfp, '| Status | Response | Action   |');

   avgcost  := 0;
   copen    := 0;
   cclosed  := 0;
   totlist  := 0;
   line     := 1;
   page     := 1;  { reset page num }

   while not eof(fp) do
     begin
      getdate(y, m, d, dow);
      gettime(h, mn, ss, ms);

      read(fp, dat);
         status('Parsing entry #C' + appendzero(dat.logno) + dat.logty + '...');
      writeln(logfp, '[',d,'/',m,'/',y,' ',h,':',mn,':',ss,'] Parsing database entry #C', dat.logno);

      with dat do
       begin
        logty := upcase(logty);
        invno := upper(invno);
        invda := upper(invda);
        custn := upper(custn);
        prod1 := upper(prod1);
        resp  := upper(resp);
       end;

      show := false;

      if sel = 1 then { log no }
       begin
        if (dat.logno >= dat1.logno) and (dat.logno <= dat2.logno) then
          show := true;
       end
      else if sel = 2 then { log date }
       begin
         if (dat.logyr >= dat1.logyr) and (dat.logyr <= dat2.logyr) then
         if (dat.logmo >= dat1.logmo) and (dat.logmo <= dat2.logmo) then
          if (dat.logda >= dat1.logda) and (dat.logda <= dat2.logda) then
           show := true;
       end
      else if sel = 3 then { logty }
       begin
        if (dat.logty = dat1.logty) then
         show := true;
       end
      else if sel = 4 then { resp }
       begin
        if (dat.resp = dat1.resp) then show := true;
       end
      else if sel = 5 then { cost }
       begin
        if (dat.cost >= dat1.cost) and (dat.cost <= dat2.cost) then show := true;
       end
      else if sel = 6 then { stats }
       begin
        if (dat.stats = dat1.stats) then show := true;
       end
      else if sel = 7 then { rtime }
       begin
        if (dat.rtime >= dat1.rtime) and (dat.rtime <= dat2.rtime) then show := true;
       end
      else if sel = 8 then show := true; { all }

      if (show = true) then
       begin
         { screen log }
         status('Listing #C' + appendzero(dat.logno) + dat.logty + '...');
         writeln(logfp, '[',d,'/',m,'/',y,' ',h,':',mn,':',ss,'] Listing entry #C', appendzero(dat.logno) + dat.logty);

         { seperators + intelligent paging system }
         if line = linesperpage then
          begin
           write(outfp, '\par ========================================================================================');
           writeln(outfp, '=======================================================================================');
           writeln(outfp, '\par ');
           writeln(outfp, '\par Page ', page);
           writeln(outfp, '\par');
           write(outfp, '\par                                                                                   ');
           writeln(outfp, '                           YENOM Label Materials (S) Pte Ltd -- Quality Control/IT Department');
           writeln(outfp, '\page ');
           writeln(outfp, '\par YENOM LABEL MATERIALS (S) PTE LTD/QA COMPLAINT REPORT');
           writeln(outfp, '\par ');
           writeln(outfp, '\par Continued from page ', page, '...');
           writeln(outfp, '\par ');
           write(outfp, '\par ========================================================================================');
           writeln(outfp, '=======================================================================================');
           page := page + 1;
           line := 1;
          end
         else
          begin
           write(outfp, '\par +------------+------------+--------------------------------+');
           write(outfp, '---------------------------+-------------------------------------+');
           writeln(outfp, '-----------------+--------+----------+----------+');
           line := line + 1;
          end;

         { line 1 }
         write(outfp, '\par | C', appendzero(dat.logno), dat.logty);
         write(outfp, '     | ', appendspc(10,truncs(8, dat.invno)));
         write(outfp, ' | ', appendspc(30,truncs(30, dat.custn)));
         write(outfp, ' | ', appendspc(25,truncs(25, dat.prod1)));
         write(outfp, ' | ', appendspc(35,truncs(35, dat.comp1)));
         write(outfp, ' | ', dat.cost:15:2);
         write(outfp, ' | ', appendspc(6,returnstats(dat.stats)));
         write(outfp, ' | ', appendspc(3,getrtime(dat.rtime)), ' days | ');
         writeln(outfp, appendspc(8,returnact(dat.actpl)), ' |');
         { line 2 }
         write(outfp, '\par | ', dat.logda:2, '/', dat.logmo:2, '/', dat.logyr:4);
         write(outfp, ' | ', appendspc(10,truncs(10, dat.invda)));
         write(outfp, ' +--------------------------------+ ');
         write(outfp, appendspc(25,truncs(25, dat.prod2)));
         write(outfp, ' | ', appendspc(35,truncs(35, dat.comp2)));
         write(outfp, ' |                ');
         write(outfp, ' |       ');
         writeln(outfp, ' |          |          |');
         { line 3 }
         write(outfp, '\par |            |            | ');
         write(outfp, appendspc(30,truncs(30, dat.resp)), ' | ');
         write(outfp, '                          | ');
         write(outfp, appendspc(35,truncs(35, dat.comp3)));
         writeln(outfp, ' |                 |        |          |          |');

         totlist := totlist + 1;
         if avgcost >= 0 then avgcost := avgcost + dat.cost;
         if dat.stats = true then copen := copen + 1
         else cclosed := cclosed + 1;
       end
     end;

   {footer}
   writeln(logfp, '[',d,'/',m,'/',y,' ',h,':',mn,':',ss,'] Writing report footers...');
   write(outfp, '\par ========================================================================================');
   writeln(outfp, '=======================================================================================');
   writeln(outfp, '\par Total pages: ', page);
   writeln(outfp, '\par');
   writeln(logfp, '[',d,'/',m,'/',y,' ',h,':',mn,':',ss,'] Calculating summary data...');
   write  (outfp, '\par Total cost impact      : S$', avgcost:0:2);
   writeln(outfp, '\par Total no. of complains : ', totlist);
   writeln(outfp, '\par Total cases open/closed: ', copen, '/', cclosed);
   writeln(outfp, '\par');
   write(outfp, '\par                                                                              ');
   writeln(outfp, '                                YENOM Label Materials (S) Pte Ltd -- Quality Control/IT Department');
   writeln(outfp, '\par }}');
   writeln(logfp, '[',d,'/',m,'/',y,' ',h,':',mn,':',ss,'] Ending report file session...');
   { close }
   close(fp);
   close(outfp);
   close(logfp);
   print(outtxt);
 end;

procedure showMenu_VIEW;
 var
  datfp: file of complaintT;
  dat: complaintT;
  e: char;
  i, xa, tr: longint;
  s: array[0..8] of char;

 begin
  textcolor(fgcolor);
  textbackground(bgcolor);
  clrscr;
  centerln('VIEW COMPLAINT RECORD(S)');
  writeln;

  e := #77;
  i := 0;
  xa := 0;

  filesearch(s, datfile, datpath);

  if s[0] = #0 then
   begin
    status('Database file does not exist. Please add a record to create it.');
    textcolor(alcolor);
    writeln('ERROR: Data file "' + datfile + '" dose not exist!');
    resetcolor;
    writeln;
    writeln('You cannot use this feature until you have created a data file');
    writeln('by adding a complaint record!');
    writeln;
    writeln('This session will terminate. Press a key...');
    readkey;
    exit;
   end;

  status('Calculating total number of records, please wait...');
  assign(datfp, datpath + datfile);
  reset(datfp);
   tr := 0;
   while not eof(datfp) do
    begin
      read(datfp, dat);
      tr := tr + 1;
    end;

  while (e <> #27) do
   begin
    status('Parsing database, please wait...');
    reset(datfp);

    if e = 'R' then
     begin
      tr := 0;
      status('Re-calculating total number of records, please wait...');
      while not eof(datfp) do
       begin
         read(datfp, dat);
         tr := tr + 1;
       end;
      status('Refreshing record, please wait...');
      reset(datfp);
      for i := 1 to xa do
        read(datfp, dat);
     end
    else if (e = #77) or (e = #81) then
      begin
       if e = #77 then xa := xa + 1
       else if e = #81 then xa := xa + 10;

       if xa > tr then
        begin
         beep;
         xa := tr;
        end;

       for i := 1 to xa do
        read(datfp, dat);
      end
    else if (e = #75) or (e = #73) then
      begin
       if e = #75 then xa := xa - 1
       else if e = #73 then xa := xa - 10;

       if xa < 1 then
        begin
         beep;
         xa := 1;
        end;

       for i := 1 to xa do
        read(datfp, dat);
      end;

       begin
        clrscr;
        status('LEFT=Previous, RIGHT=Next, A=Add, D=Delete, E=Edit. Hit F1 for more help.');
        centerln('VIEW COMPLAINT RECORD(S)');
        writeln;
        gotoxy(45,wherey);
        write(' Record No. ');
        drawfield(17);
        with dat do
         writeln('C', appendzero(logno), logty, '/', logda, '/', logmo, '/', logyr);
        resetcolor;

        writeln;
        write('  Invoice No.   ');
        drawfield(15); writeln(dat.invno); resetcolor;

        writeln;
        write('  Invoice Date  ');
        drawfield(15); writeln(dat.invda); resetcolor;

        writeln;
        write('  Customer Name ');
        drawfield(57); writeln(truncs(55, dat.custn)); resetcolor;

        writeln;
        write('  Sales Staff   ');
        drawfield(57); writeln(truncs(55, dat.staff)); resetcolor;


        writeln;
        writeln('  Defective Product(s)');
        write('     a. '); drawfield(65); writeln(truncs(63,dat.prod1)); resetcolor;
        write('     b. '); drawfield(65); writeln(truncs(63,dat.prod2)); resetcolor;

        writeln;
        writeln('  Nature of Complaint');
        write('     a. '); drawfield(65); writeln(truncs(63,dat.comp1)); resetcolor;
        write('     b. '); drawfield(65); writeln(truncs(63,dat.comp2)); resetcolor;
        write('     c. '); drawfield(65); writeln(truncs(63,dat.comp3)); resetcolor;

        writeln;
        write('  Resposibility ');
        drawfield(20); writeln(dat.resp); resetcolor;

        writeln;
        write('  Cost Impact   ');
        drawfield(20); writeln('S$', dat.cost:0:2); resetcolor;

        writeln;
        write('  Status        ');
        drawfield(10); writeln(returnstats(dat.stats)); resetcolor;

        writeln;
        write('  Response Time ');
        drawfield(10);
        if dat.rtime <= 0 then
         writeln('N/A')
        else
         writeln(dat.rtime, ' days');
        resetcolor;

        writeln;
        write('  Action Plan   ');
        drawfield(10); writeln(returnact(dat.actpl)); resetcolor;
       end;

      writeln;
      writeln;
      writeln;
      writeln;
      centerln('Press F1 for Usage Help');
      writeln;

      if xa = tr then centerln('*** Last Record ***')
      else if xa = 1 then centerln('*** First Record ***');

      resetcursor;
      e := readkey;
      e := upcase(e);

      with dat do
       begin
        if e = 'A' then showMenu_ADD
        else if e = 'E' then showMenu_EDIT(logno)
        else if e = 'D' then showMenu_DEL(logno)
        else if e = 'P' then showMenu_PRINT
        else if e = 'L' then xa := tr
        else if e = 'F' then xa := 1;
       end;

      if (e = 'E') or (e = 'D') or (e = 'P') or (e = 'L') or (e = 'F') then e := 'R';

      if e = #0 then
       begin
        e := readkey;
        if e = #72 then e := #75
        else if e = #80 then e := #77
        else if e = #59 then
         begin
           gotoxy(1,5);
           textcolor(hfcolor);
           textbackground(hbcolor);
           centerln('ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»');
           centerln('º                                      º');
           centerln('º  VIEW COMPLAINTS RECORD HELP SCREEN  º');
           centerln('º                                      º');
           centerln('º  Key          Function               º');
           centerln('º  ----------------------------------  º');
           centerln('º  LEFT ARROW   Previous record        º');
           centerln('º  RIGHT ARROW  Next record            º');
           centerln('º  PAGE UP      Previous 10 records    º');
           centerln('º  PAGE DOWN    Next 10 records        º');
           centerln('º                                      º');
           centerln('º  A            Add a new entry        º');
           centerln('º  D            Delete current entry   º');
           centerln('º  E            Edit current entry     º');
           centerln('º  F            Go to the first entry  º');
           centerln('º  L            Go to the last entry   º');
           centerln('º  P            Print a report         º');
           centerln('º                                      º');
           centerln('º  ESC          Exit this screen       º');
           centerln('º                                      º');
           centerln('º  Press a key...                      º');
           centerln('º                                      º');
           centerln('ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼');
           resetcolor;
           resetcursor;
           e := readkey;
           if e = #0 then e := readkey;
           e := #59;
         end;
       end
      else if (e <> #27) and (e <> 'R') then e := #0;

  end;

  close(datfp);

 end;

var
 passwdretry, select: byte;
 passwdstat: boolean;
 tmpfp: text;
 data1f, data2f: file of ComplaintT;
 data: complaintT;
 key1f, key2f: file of KeyT;
 key: keyT;
 i: integer;
 s: array[0..8] of char;
 quit: boolean;

begin

  { init screen }
  setScr;
  setTitle;

  { security feature begin }
  passwdretry := 1; { var stores no of password retries }

  while (1=1) do
   begin
    passwdstat := getPasswd; { password input }

    { check validity }
    if (passwdstat = true) then break
    else if passwdretry < 3 then inc(passwdretry)
    else
     begin
      textmode(CO80);
      clrscr;
      writeln('SECURITY ERROR: Password failure after 3 retries, program exiting...');
      writeln;
      writeln('Press a key...');
      readkey;
      writeln;
      exit;
     end;
   end;

  { init cofig and paths etc }
  createdir('.\' + tmpcpat);
  createdir('.\' + logcpat);
  createdir('.\' + bupcpat);
  createdir('.\' + cfgcpat);

  { begin loop for main screen }
  select := 1;
  quit   := false;
  while (quit = false) do
   begin
     select := showMenu(select);
     if select = 1 then showMenu_ADD
     else if select = 2 then showMenu_EDIT(-1)
     else if select = 3 then showMenu_VIEW
     else if select = 4 then showMenu_DEL(-1)
     else if select = 5 then showMenu_PRINT
     else if select = 6 then
       begin
         status('Hit "Y" to quit, "N" to return to main menu.');
         gotoxy(1,13);
         textcolor(hfcolor);
         textbackground(hbcolor);
         centerln('ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»');
         centerln('º                                      º');
         centerln('º Are you sure you want to quit? (Y/N) º');
         centerln('º                                      º');
         centerln('ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼');
         resetcolor;
         resetcursor;
         if (upcase(readkey) = 'Y') then quit := true;
       end;
   end;

  { back to old dos mode }
  textmode(CO80);
  clrscr;
  { cleanup tmp }
  writeln('Cleaning up temporary file(s)... ');
  assign(tmpfp, tmppath + 'DATA.TMP');
  rewrite(tmpfp);
  write(tmpfp, '$');
  close(tmpfp);

  filesearch(s, datfile, datpath);

  if s[0] <> #0 then
   begin
    writeln('Making backup copy of ' + datfile + ' to ' + buppath + 'DATA.BAK...');
    assign(data1f, datpath + datfile);
    assign(data2f, buppath + 'DATA.BAK');
    reset(data1f);
    rewrite(data2f);
    i := 1;
    while not eof(data1f) do
     begin
      read(data1f, data);
      write(data2f, data);
      inc(i);
     end;
    close(data1f);
    close(data2f);
   end;

  filesearch(s, keyfile, datpath);

  if s[0] <> #0 then
   begin
    writeln('Making backup copy of ' + keyfile + ' to ' + buppath + 'KEY.BAK...');
    assign(key1f, datpath + keyfile);
    assign(key2f, buppath + 'KEY.BAK');
    reset(key1f);
    rewrite(key2f);
    while not eof(key1f) do
     begin
      read(key1f, key);
      write(key2f, key);
     end;
    close(key1f);
    close(key2f);
   end;

  writeln;
  writeln('Copyright(c) 1999-2000, Lee Ting Zien.');
  writeln;
end.