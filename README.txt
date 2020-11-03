-----------------------------------------------------------------------
 YENOM QUALITY CONTROL DEPARTMENT COMPLAINT LOGGING AND REPORT SYSTEM
-----------------------------------------------------------------------
README FILE FOR VERSION 4.31                              2nd May, 2000
-----------------------------------------------------------------------

TABLE OF CONTENTS

  General Information............................A
    Platforms....................................A1
    User Interface...............................A2
    Source Codes.................................A3
    Documentation................................A4

  Changes........................................B
    Modules Added................................B1

  Known Bugs and Fixes...........................C

  Software Notes.................................D

  Contact Information and Credits................E

  Documentation Availability.....................F

  Future Software Updates........................G

  GNU General Public Licence Notes...............H





    *** The contents of this README file is not to be modified. ***


  This program is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation; either version 2 of
  the License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public
    License along with this program; if not, write to the Free
    Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
    MA  02111-1307  USA

  Please refer to section H for more information on the GNU General
  Public Licence.



  Copyright(c) 2000, Lee Ting Zien. All Rights Reserved.



-----------------------------------------------------------------------
A. GENERAL INFORMATION

  Programmer   : Lee Ting Zien
  Documentation: README.TXT/Printed on paper
  Language     : Turbo Pascal, Borland 7.0 compatible
  Ext Units    : None other than those provided with BTP7.0
  Start Date   : 30th Jan 2000
  Last Modified: 02nd May 2000
  Version      : v4.31 Commercial Release


  A1. Platforms

      This software is known to work with all x86 Microsoft operating
      systems. Tested platforms include: -
      - MS-DOS 6.22
      - Microsoft Windows 95/Windows 98
      - Microsoft Windows NT 4.0 Sever/Workstation (Up to SP6)
      - Windows 2000 Professional Build 2020 Beta 3 and 2815 Free

      The reporting features of this software is only known to work
      with Windows 95/98 where an RTF capable viewer is able to
      launch via `START <FILE>.RTF'.

      Anybody with a Linux Borland Pascal compatible compiler can
      freely test this software on a Linux platform. I would be
      looking forward to the performance of Linux's VT. Do let me
      know.

      I figured there might be some difficulties you may encounter
      which will cause you to modify my code. Some of which would
      be using the SVGATextmode package for switching to 80x50 mode
      before operating this software.

      The Redhat RPM for SVGATextMode can be obtained from: -
        ftp://ftp.hjc.edu.sg/linux/redhat/redhat-6.2/i386/RedHat/RPMS

      ... or any other RedHat FTP sites.

      And also the report generating function would not work unless
      you can find a Linux RTF file viewer.

      This software was initially developed with the aim of a simple
      reporting system which works under a Windows-based enviroment,
      not for mass distribution and cross-platform compatibility,
      thus the RTF file format.



  A2. User Interface

      Since version 0.2beta till this current version, it was
      developed under an MS-DOS IDE enviroment, thus the old MS-DOS
      screen. I am a Pascal programmer in JC (refuse to name, 'coz
      they can't teach properly, I had to learn myself.) so please
      don't complain about the old DOS look. I have just picked up
      PERL, PHP3, Java, so allow me to make a better version of this
      program over some longer period of time.

      Selection menus are navigable via arrow keys (either up/down
      or left/right), popup screens might require a single keystroke
      (e.g. `Y') or you may need to hit enter after a key stroke.

      Data entry fields requires an ENTER at the end of the line to
      proceed to the next data field. You cannot return to the
      previous field once you hit ENTER. You need to edit the entry
      after you have added it to correct any mistakes.

      As a limitation of the software compiler I used, it will crash
      if you entered a value which is supposed to be a number as a
      series of characters. Examples are values of money. An attempt
      to enter "ABCD" instead of "123.12" will crash the software.



  A3. Source Codes

      As a thought, I decided to release v4.30c's source code (TP7)
      together with it's binary distribution on 28/03/2000. This
      software will now be licenced under the GNU General Public
      Licence (See section H) In such cases, items `D(1-4)' of this
      README.TXT file will be invalid.

      Why I released the source? Well, no idea. Maybe because I
      wanted to make this world a better place, maybe because I
      _THINK_ Turbo Pascal is a louzy language. Well, whatever, you
      figure it yourself. My source izn't that great anyway.

      Source code files: -
        COMPLAIN.PAS - The main program source, one whole file
                       Requires: Borland Pascal 7.0 basic units
                                 SYSTEM.TPU, DOS.TPU, WINDOS.TPU
        CONVERT.PAS  - Simple database converter source
        PERFTEST.PAS - Huge database file generator source



-----------------------------------------------------------------------
B. Changes

  The following are a list of changes for every release verion of
  this software: -

  v4.31c
    - Fixed problem which confused summary report data for "Average/
      Total Cost Impact". Average cost impact data has been removed.

  
  *** All previous verion changes were not tracked due to huge changes
      in the software.



  B1. Modules added
    1. Database version 3 (DBv3)
       - Added action field (from DBv2)
       - Added extra line for field "Complaint Nature"
    2. Performance mode (PerfM)
       - Tested with 20,000 entries on a Pentium 60MHz 16MB
       - Improved report exporting speed
       - Improved add/view/edit/delete speed
       - PERFTEST.EXE random DB generator (DBv2 ONLY)
         Use CONVERT.EXE to convert to DBv3
       - Turbo speed mode after version 4.20
    3. Enhanced User Interface Version 2 (EnUI2)
       - Report generation screen uses arrow key selection
       - Improved report filter selection screen in v4.3x and above
       - Confirmation prompts and status bar
       - Displays "First Entry!" and "Last Entry!" during view
       - F1 help popup screen for View mode
       - Exit software confirmation
       - Password entry only accepts A..Z, a..z, 0..9, "-" and "_"
         characters for input.
       - Corrected minor interface bugs
    4. Enhanced Reporting System
       - Incooperated with PrefM, improved report generation speed
       - Direct RTF file generation; Faster (no more TXT->RTF)
       - Paginating ability prevents fields from being cut off
         and clearer report printouts
       - Resized table column width to cater to more realistic use
       - Logging for report generation for debugging purposes



-----------------------------------------------------------------------
C. Known Bugs and Fixes

    The following are known bugs (and temp. fixes) as of the current
    version.

    +- LEGEND --------------------------+
    |  [B] = BUG       [F] = FIX        |
    +-----------------------------------+

    [B] Software crashes if it fails to get access permission to open
        or write a file. This happens when there are multiple users
        on the network.
    [F] Get everybody off the network. Heh.


    [B] Software crashes if user attempts to view/edit/delete/print
        when no entry exist in an existing database file
    [F] Delete the database files if there aren't any entries. The
        file to delete is DATA.DA3


    [B] Software crashes if user attempts to delete the only entry
        in the database
    [F] Delete the database file "DATA.DA3" itself.


    [B] HELP! I terminated the program during the first run when
        it prompted me for a password. Now I can't enter the software
        without a password. What should I do?
    [F] Calm down! Delete the password file, SEC.DAT, and run the
        software again to set a new password.


    [B] NOT a bug, but a UI problem. Unable to move around fields
        with arrow keys.
    [F] Those who are interested in developing a web-based port of
        this software may contact me. It should solve all the problems
        listed above.



-----------------------------------------------------------------------
D. Software Notes

        ***      ITEMS 1-4 IS OBSELETE SINCE V4.30      ***
        *** DUE TO RELEASE OF SOURCE CODE DISTRIBUTABLE ***
        ***    UNDER THE GNU GENERAL PUBLIC LICENCE     ***

    1. None, part or whole of this program shall be copied without
       prior permission from the author of this software
    2. This software shall not be revese engineered
    3. Distribution of this software is strictly prohibited
    4. This software is solely developed and licenced to YENOM Label
       Materials (S) Pte Ltd QA Department
    5. MS-DOS, Windows, Wordpad and Word(tm) are registered
       trademark(s) of Microsoft(r) Cooperation.



-----------------------------------------------------------------------
E. Contact Information and Credits

     Name   : Lee Ting Zien
     E-mail : detach8@hotmail.com

       Developed the QA system, wrote this README, and almost
       everything else related.



-----------------------------------------------------------------------
F. Documentation Availability

      Documentation will be released soon in HTML format. I'm very
      busy nowadays with my work so those who wish to aid me in this
      can contact me. (See section E)



-----------------------------------------------------------------------
G. Future Software Updates

   The software should be more flexible by being able to read from
   and write to a configuration file, where information of user
   customisable currency and decimal notations, colours, etc. can
   be stored and then retrieved.

   However I'm busy with my other projects. If the above is not
   fufilled then... (read below)

   I intend to migrate this whole software to a fully web-based
   multi user client-server application using a commercial database
   systems like MSSQL or MySQL.

   Since the de-facto standard nowadays for a user interface is the
   web, this shouldn't be missed out. :)



-----------------------------------------------------------------------
H. GNU General Public Licence Notes

   Please refer to the file "GNUGPL.TXT" included with the default
   archived distribution of this software.

-----------------------------------------------------------------------
                                       Copyright(c) 2000, Lee Ting Zien
