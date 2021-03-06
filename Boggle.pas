program boggle;
uses wincrt, windos, strings;
type ar1 = array[1..16] of string[6];    {dice array}
     ar2 = array[1..16] of string[16];   {positions of each letter in word}
     ar3 = array[1..150] of string[16];  {different possible combination array}
     ar4 = array[1..50] of string[16];   {wordstore}
     reco = record                       {used for incorrect words and highscores}
               word : string[16];        {word or name}
               reason : integer;         {reason or score}
               end;
     grid = array[1..2] of reco;   {incorrect words array}
     bits_of_info=file of reco;
var count, letters, wordcount, points, spot, refresh:integer;
    words, board : string[16];
    a : char;
    highscores : array[1..11] of reco;
    data: text;
    dice : ar1;
    positions : ar2;                      {variables}
    datas : bits_of_info;
    combo : ar3;
    wordstore : ar4;
    incorrectwords : grid;
    validity : boolean;
    full : array[1..30] of string;

{---------------------------------------------------------------------------------------------------------------------------}

procedure screen;                      {this procedure simply makes the main playing UI}
begin
writeln('Boggle By Sean Darcy');
for count := 1 to 80 do
    write('_');

gotoxy(66,4);
writeln('Playing Board');
gotoxy(68,5);
writeln('_________');
for count := 6 to 10 do
begin
     gotoxy(67,count);
     writeln('|         |');
end;
gotoxy(67,11);
writeln('|_________|');
gotoxy(68,18);
writeln('TTTTTTTTT');
for count := 19 to 21 do            {it writes very messily where all the lines and boxes should go}
begin   
        gotoxy(68,count);
        writeln('T       T');
end;
gotoxy(68,22);
writeln('TTTTTTTTT');
gotoxy(67,23);
writeln('Seconds Left');
for count := 3 to 24 do
begin
    gotoxy(60,count);
    writeln('|');
end;
gotoxy(61,13);
writeln('____________________');
gotoxy(70,16);
writeln('TIMER');                                                                    
gotoxy(70,17);
writeln('`````');
gotoxy(1,22);
for count := 1 to 59 do
    write('_');
gotoxy(44,18);
writeln('________________');
gotoxy(43,19);
writeln('|incorrect words:');
for count := 20 to 22 do
begin
     gotoxy(43,count);
     write('|');

end;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure readdice;            {reads information from dicedet to use in boardgenerator}
var index: integer;
begin
assign(data,'data/dicedet.txt');{dice details is a text file containing 16 lines of 6 character strings}
reset(data);                    {ie 16 dice each with 6 sides, so if you were really botehred you could}
index:= 1;                      {go into this file and make your own dice, but the current dice are the ones}
repeat                          {that are standard for real boggle and generally makes pretty good boards}
    readln(data,dice[index]);
    inc(index);
 
until index = 17;
close(data);
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure boardgenerator;        {this randomly generates the board, taking info from dice det}
type records = record            {so that all boards make are actually possible in a real}
     letter : integer;           {game of boggle}
     pos: integer;               {and then it writes the board to random}
     end;
     arrayofrecords = array[1..16] of records;
var index, counter, postest : integer;
    board : arrayofrecords;
    unique : boolean;
begin
randomize;
assign(data, 'data/random.txt');
reset(data);
rewrite(data);
for index := 1 to 16 do
begin
    board[index].letter := random(6)+1; {this gets the side, 6 sides on a dice}
    board[index].pos := 17;
    repeat
    unique := true;
    postest := random(16)+1;   {this choses which dice from the 16}
    for counter := 1 to index do
        if postest = board[counter].pos then
           unique := false;            {but has to be checked cause you cannot use a dice twice}
    until unique = true;
    board[index].pos := postest;
    writeln(data, board[index].letter); {saves the details in 2 rows for every dice, the side then the dice}
    writeln(data, board[index].pos);    {this means the first 2 lines mean the first position of the board with the stated}
end;                                    {dice and side of that dice}
close(data);
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure rantoboard;   {this takes the saveed file from boardgenerator and puts it in the}
var                     {variable board}
   temppos, templetter: integer;
   tempdice : string[6];
begin
readdice;
assign(data, 'data/random.txt');
reset(data);
count := 1;
board := '                ';
repeat
readln(data, templetter);
readln(data, temppos);          {reads the random dice file made by boardgenerator}
tempdice := dice[temppos];      { this could be in a single procedure but for the }
board[count] := tempdice[templetter]; { cheat module u need to be able to read the board }
inc(count);                           {without generating a new board}
until count > 16;
close(data);
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure boardwriter;   {writes the board onto the screen, 4 by 4}
var index, y : integer;
begin
count := 1;
y := 7;
repeat   {repeats for all 16 letters}
index := 1;
gotoxy(69,y);
repeat       {repeats for 4 times in a row}
write(board[count],' ');
inc(count);
inc(index);
until index > 4;
inc(y);
until count > 16;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure combos(length : integer ;var possiblecombo : integer);
var diffpos,code, index: integer;    {when a word is created this finds out how many }
    temp : string[16];               {different possible versions of the word are on the board}
begin                                {ie a word can one of 2 a's on the board}
possiblecombo := 1;
diffpos := 1;
count := 0;
repeat    {repeats for every letter in word}
     inc(count);
     temp := positions[count];    {positions[count] is an array with 1 to length of word, and each }
     val(temp[1],diffpos,code);   {entity is hex chars representing where that letter is on the board}
     if count >= 2 then           { the first char however is how many times that letter appears on board}
        for index := 1 to count - 1 do
            if temp = positions[index] then {so diffpos is how many times that letter appears on board}
               dec(diffpos);                {this is then decremented for every time the letter appears in}
     possiblecombo := possiblecombo*diffpos; {the word more than once}
until count = length;           {multiplying this for every letter in word makes total different positions}
end;                            {took a while to figure this out but it works}

{---------------------------------------------------------------------------------------------------------------------------}

procedure resetarray;    {resets the positions and combo arrays when a new word is entered}
begin
for count := 1 to 16 do
begin
    positions[count] := '                ';
    combo[count] := '                ';
end;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure combomaker(length, possiblecombos : integer);
var temp, position : string[16];                    {generates all possible combinations of the word}
    nopos, counter, index, code, rand : integer;    {according to the board}
    unique, used : boolean;
begin
count := 1;                {makes an array of strings which instead of the word have the position of the letter on the board}
repeat                       {but may have many different combinations of positions}
  temp := '                ';       {ie the string 456 would mean the first letter is in 4th position, 2nd is in 5th etc}
  for counter := 1 to length do
  begin
    repeat
      position := positions[counter];           {gets a position of the letter at counter, randomly from positions}
      val(position[1],nopos,code);              {first digit of positions shows how many of that letter is on board}
      rand := random(nopos)+2;
      used := false;
      for index := 1 to nopos do
        if temp[index] = position[rand] then     {goes thru the string created to see if that position has been used alredy}
          used := true;
    until used = false;
    temp[counter] := position[rand];         {if it hasnt then it adds that position to the word at counter} 
  end;                                     {does this for every letter in the word to make the string}
  unique := true;
  for counter := 1 to possiblecombos do    {goes thru all of the previously made}
    if temp = combo[counter] then                           {letter combinations to make sure it hasnt been used}
       unique := false;
  if unique = true then
    begin
       combo[count] := temp;                  {if it is unique adds it to array}
       inc(count);
    end;
until count > possiblecombos;             {does this till it finds every single possible combinations}
            
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure wordstopositions(words : string; length : integer);
var temp : string[16];                             {goes thru all letters of word and makes a string} 
    position: string[1];                           {with all the positions of that letter on the board}
    counter, index : integer;                      {with the first character being the number of diff positions}
begin                                              
resetarray;	
position := ' ';
count := 0;
repeat           {for every letter in word}
  inc(count);
  counter := 1;
  temp := '         ';
  index := 0;
  repeat         {for every letter on board}
       inc(index);
       if words[count] = board[index] then{goes thru letters on board till it finds the letter from the word}
       begin                              {index then represents the position on board but this is converted to hex so it}
          if index > 10 then              {only is one char}
          begin
             case index of
              11 : position := 'A';
              12 : position := 'B';
              13 : position := 'C';    {converting the found position to hex}
              14 : position := 'D';
              15 : position := 'E';
              16 : position := 'F';
             end;
          end
          else 
            str(index - 1, position);  
          temp[counter] := position[1];   {this then adds that char to the end of temp}
          inc(counter);
       end;
       str(counter-1,position);
       if position <> '0' then     
         positions[count] := concat(position,temp);   {then temp is concatenated with how many letters were found}
  until index = 16;                                   {and written to the array}
until count = length;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure adjchecker(length, possible:integer; var adj : boolean); {checks that the word is adjacent on the board}
type tex = array[1..16] of string[13];                             {by reading details from allowed.txt}
var notallowed : tex;
    temp, tempword : string[15];
    tempadj  : boolean;           
    index, counter, i , code : integer;

{---------------------------------------------------------------------------------------------------------------------------}

begin
assign(data,'data/allowed.txt');
reset(data);                         {allowed is a 16 line text file, each line contains a list of all positions}
for count := 1 to 16 do              {that are not adjacent in the 4 by 4 grid, each line representing a diff position}
    readln(data,notallowed[count]);
close(data);
adj := false;
counter := 0;
tempword := '               ';
repeat
  inc(counter);                           {goes thru every combination and if any of these are adjacent then the word is valid}
  tempword := combo[counter];
  tempadj := true;
  index := 0;
  repeat                                 {for every letter then the combination}
    inc(index);
    case tempword[index] of
     '0'..'9':begin
                   val(tempword[index],i,code);
                   temp := notallowed[i+1];
              end;
     'A': temp := notallowed[11];
     'B': temp := notallowed[12];        {gets positions NOT allowed to follow the position the pointer is at}
     'C': temp := notallowed[13];
     'D': temp := notallowed[14];
     'E': temp := notallowed[15];
     'F': temp := notallowed[16];
    end;
    count := 0;
    gotoxy(1,5);
    repeat
      inc(count);
      if (tempword[index+1] = temp[count]) then   {if the next letter is on the list then it isnt adj} 
         tempadj := false;
    until (count = 13) or (tempword[index+1] = ' ');
  until (index = length) or (tempadj = false);
  if tempadj = true then
     adj := true;
until (counter = possible) or (adj = true);
     
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure usedalredy(words : string; var validity : boolean);    {checks if the word entered is alredy in the wordlist}
begin
for count := 1 to wordcount do
begin
     if wordstore[count] = words then
        validity := false;
end;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure displaywords;     {writes all words in the wordlist in columns}
var column, row : integer;
begin
count := 0;
column := -1;
repeat        {repeats for 50 words}
    row := count mod 18;   {18 rows a column, the last column slightly smaller to accommodate the incorrect positions box}
    if row = 0 then
       inc(column);
    gotoxy(3+column*20,4+row);
    writeln(wordstore[count+1]);
    inc(count);
until count = 50;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure dictionarycheck(words: string; var test : boolean);
var                                {checks the word against the dictionary}
   filename, extra : string;
   temp :string[16];
begin
extra := concat(words[1],words[2]);
filename := concat('dict/',extra,'.txt');
assign(data,filename);
{$I-}
reset(data);                      {the dictionary is sorted into files named by the}
{$I+}                             {first 2 letters of the word, ie cloud would be in CL.txt}
if ioresult = 0 then              {if the text file is not found immediately makes test false}
begin
test := false;
count := 0;
repeat      {goes thru every word in the dictionary file}
     inc(count);
     readln(data,temp);
     temp := concat(temp,'                 ');
     if temp = words then { until it finds the word}
        test := true;
until (count = 2000) or (test = true);
close(data);
end
else
    test := false;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure wordcheck(words: string; dictcheck : boolean; length : integer);
var onbord : boolean;                                                     {this procedure takes the word and calls}
    counter, number, bordno, tempreason, possiblecombo : integer;  {other procedures to check that the word}  
begin                                                                     {is valid}
tempreason := 0;                                                          {then writes the word in the according}
validity := true;                                                         {array}
if letters <= 3 then   {makes sure the word is > 3 letters}
begin
   validity := false;
   tempreason := 1;   {temp reason is to show where the word failed, 1 is too short}
end;
if (words[1] = 'Q') and (words[2] = 'U') then {allows the Q letter to be followed by a U to make it more useful}
begin
   delete(words,2,1);
   dec(letters);
   dec(length);
end;
count := 0;
repeat   {goes thru every letter in word and makes sure it is on the board}
   inc(count);
   onbord := false;
   counter := 0;
   bordno := 0;
   repeat
   inc(counter);
      if words[count] = board[counter] then  {but thanks to multiple letters in word/ on board has to be tested differently}
          inc(bordno);         {bordno is how many times the letter at the pointer is on the board}
   until counter = 16;
   counter := 0;
   number := 0;
   repeat
   inc(counter);
   if words[count] = words[counter] then
      inc(number);        {number is how many times the letter at the pointer is in the word}
   until counter > count;
   if bordno >= number then  {if there is more of the letter in the word than on board then it is false}
      onbord := true;
   validity := onbord;
   if validity = false then
   begin
      tempreason := 2;   {not all letters appear on board is tempreason 2}
   end;

{---------------------------------------------------------------------------------------------------------------------------}

until (count = letters) or (validity = false);
if validity = true then
begin
wordstopositions(words, length);
possiblecombo := 1;
combos(length, possiblecombo);
combomaker(length, possiblecombo);
adjchecker(length, possiblecombo, validity);  {checks if the word is adjacent}
if validity = false then
   tempreason := 3;    {tempreason 3 is word is not adjacent}
end;
if words[1] = 'Q' then           {inserts the U after the first Q to check the dictionary}
   insert('U',words,2);
if (validity = true) and (dictcheck = true) then   {when the cheater module runs it doesnt need }
begin              {to check dictionary or previously entered words, so when it runs wordcheck dictcheck = false}
usedalredy(words,validity);
if validity = false then
   tempreason := 4;   {tempreason 4 is word has alredy been used}
end;
if (validity = true) then
begin
     if dictcheck = true then
        dictionarycheck(words,validity);
     if validity = false then
        tempreason := 5    {temp reason 5 is word does not appear in dictionary}
     else
    begin
    wordstore[wordcount] := words; {adding word to the wordstore array, of correct words}
    inc(wordcount);
    end;
end;
if validity = false then
   begin
        incorrectwords[2] := incorrectwords[1];  {if word is incorrect then it is added to incorrect array}
        incorrectwords[1].word := words;         {array is only 2 positions tho}
        incorrectwords[1].reason := tempreason;  {then saves why the word did not pass the test}
   end;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure displayincorrect;        {this procedure writes the incorrect words to the screen}
begin                              {and the reason why it is incorrect depending on what procedure}
        for count := 1 to 2 do     {returned a false}
            begin
             gotoxy(44,19+count);
             write(incorrectwords[count].word);
            end;
        case incorrectwords[1].reason of
             1 : begin
               gotoxy(10,24);
               writeln('Word is Too Short');
               end;
             2 : begin                                                          {indicated by tempreason}
               gotoxy(10,24);
               writeln('All of the letters are not on the Board');
               end;
             3 : begin
               gotoxy(10,24);
               writeln('All of the letters are not adjacent on the board');
               end;
             4 : begin
               gotoxy(10,24);
               writeln('Word alredy used');
               end;
             5 : begin
               gotoxy(10,24);
               writeln('Word is not in dictionary');
               end;
        end;
refresh := 0;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure update;    {after a word in entered this procedure writes it to the screen}
begin
if validity = false then
   displayincorrect   {word is wrong the incorrect list is updated}
   else
   displaywords;      {word is right the correct list is updated}
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure scorer(size:integer); {this takes the size of the word and adds points accordingly}
begin
case size of
     4: points := points +1;   {word 4 letters long gets 1 point, etc}
     5: points := points +2;
     6: points := points +3;
     7: points := points +5;
     8..14: points := points + 11;
     end;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure letterentered(letter : char);   {this reads the letter pressed, error traps, deletes and calls wordcheck}
var ordcar: integer;              {when enter is pressed}
begin
letter := upcase(letter);
ordcar := ord(letter);
if ordcar = 8 then          {when delete is pressed, clears the previous letter}
   begin
   words[letters] := ' ';
   if letters > 0 then
   dec(letters);
   end
else if ordcar = 13 then   {when enter is pressed, calls wordcheck}
     begin                 {also edits the word if it starts with Q}
     if (words[1] = 'Q') and (words[2] <> 'U') then
     begin
        insert('U',words,2);
        inc(letters);
     end;
     wordcheck(words, true, letters);
     update;
     if validity = true then
        scorer(letters);
     letters := 0;
     words := '                ';
     end 
else if (ordcar > 64) and (ordcar < 91) and (letters < 15) then   
begin                      {makes sure key is A to Z and the word is less than 15 chars long}
     inc(letters);
     words[letters] := letter;
     end;
     for count := 1 to 15 do
     begin
         gotoxy(4+count*2,23);
         write(words[count]);
     end;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure loadhigh;     {reads the highscore.dat into the array}
begin
assign(datas,'highscore/highsco.dat');
reset(datas);
for count := 1 to 10 do
begin
    read(datas,highscores[count]);
end;
close(datas);
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure addtohigh(name : string);
var                    {adds the highscore achieved to the end of the highscore array}
   tempname : string;
   tempscore : integer;
   swapped : boolean;
begin
highscores[11].reason := points;
highscores[11].word := name;
swapped := true;
while (swapped = true) do
begin
  swapped :=false;
  count := 1;
  while(count < 11) do
  begin               
    if highscores[count].reason<highscores[count+1].reason then
    begin
      tempname:=highscores[count].word;
      highscores[count].word:=highscores[count+1].word;
      highscores[count+1].word:= tempname;       {bubble sort to get the highscore to the}
      tempscore:=highscores[count].reason;       {appropriate position}
      highscores[count].reason:=highscores[count+1].reason;
      highscores[count+1].reason:= tempscore;
      swapped := true;
    end;
    inc(count);
  end;
end;
assign(datas,'highscore/highsco.dat');
rewrite(datas);
for count := 1 to 10 do            {saves the array from 1 to 10, leaving out the lowest score}
    write(datas, highscores[count]);
close(datas);
     
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure highscorecheck(var check : boolean);
begin                                   {checks the score achieved, and sees if it is good enough for a highscore}
if points > highscores[10].reason then
   check := true;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure highscorepos(var rank : integer);
begin                                  {if highscorecheck returns a true value then this finds where it is placed}
count := 10;
   repeat
   dec(count);
   until (highscores[count].reason < points) and (highscores[count-1].reason >= points) or (count = 1);
   rank := count;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure savehighdata(rank : integer);   {all highscores are saved to an individual file with details, ie words entered}
var                                       {this rewrites all files so that the new highscore is in the appropriate position}
    filename, filename2, name, highdice : string;
    thewords : ar4;
    index : integer;
begin
count := 10;
repeat
  str(count,name);
  filename2 := concat('highscore/',name,'.txt');  {all save games are saved to individual text files}
  dec(count);
  str(count,name);
  filename := concat('highscore/',name,'.txt');
  assign(data,filename);
  reset(data);                                 {writes all text files that need to be updated}
  readln(data,highdice);
  for index := 1 to 50 do
      readln(data,thewords[index]);
  close(data);
  assign(data,filename2);
  rewrite(data);
  writeln(data,highdice);
  for index := 1 to 50 do
    writeln(data, thewords[index]);
  close(data);
until count = rank+1;
str(rank,name);
filename := concat('highscore/',name,'.txt');
assign(data,filename);
rewrite(data);
writeln(data,board);
for index := 1 to 50 do
    writeln(data,wordstore[index]);
close(data);
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure savehighs;         {saves the new highscore array to file}
begin
assign(datas,'highscore/highsco.dat');
rewrite(datas);
for count := 1 to 10 do
    write(datas, highscores[count]);
close(datas);
end;

{---------------------------------------------------------------------------------------------------------------------------}

Procedure gameover;        {after the timer is up, this procedure is called and it calls all the highscore}
var highscore : boolean;   {procedures if required}
    name : string;
    counter : longint;
    rank : integer;
begin
highscore := false;
clrscr;
writeln;
writeln;
writeln;
writeln;
writeln('            _____                                        ');
writeln('           / ___/___ _ __ _  ___   ___  _  __ ___  ____  ');   {ascii art}
writeln('          / (_ // _ `//  " \/ -_) / _ \| |/ // -_)/ __/  ');   {no need for colours or pictures}
writeln('          \___/ \_,_//_/_/_/\__/  \___/|___/ \__//_/     ');
writeln('                           Score = ',points);
loadhigh;
highscorecheck(highscore);
if highscore = true then
   highscorepos(rank);
counter := 0;
repeat
  inc(counter);        {provides a wait before highscore is displayed}
until counter = 70000000;
if highscore = true then
begin
   Writeln('                    Congratulations Your got a High Score');
   writeln;
   writeln;
   write('Please Enter Your Name:');
   readln(name);
   writeln('Saving Please Wait...'); {saving highscore textfiles can sometimes have a time wait}
   addtohigh(name);
   savehighdata(rank);
   savehighs;
end;
writeln;
writeln;
writeln('Press anykey to return to the Menu');
readkey;

end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure inputtimer;       {this keeps the time, writes it to screen, and reads the key to write it to}
var hour, min, seconds, hund, inmin, insec: word;      {letterentered}
    timeleft, sechek, index : integer;
    over : boolean;
    key : char;
begin
index := 1;
gettime(hour, min, seconds, hund);
over := False;
sechek := seconds;
timeleft := 181;   {change if your want a different time}
count := 0;
repeat
repeat
      gettime(hour, min, seconds, hund);
      if seconds <> sechek then
      begin
      timeleft := timeleft - 1;
      sechek := seconds;
      gotoxy(71,20);
      writeln(timeleft:3);
      inc(refresh);
      if refresh = 2 then
         begin      {this clears the area on the screen that says why a word was incorrect}
         gotoxy(10,24);  {refresh is set to zero when it is written and every second it increments}
         writeln('                                                 ');
         end;
      end;
      if timeleft = 0 then
         over := True; 
                                
until (keypressed) or (over = True); {if a key is pressed}
if over <> true then
begin
    key := readkey;    {runs letter entered if there is still time left}
    letterentered(key);
    end;
until over = true

end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure instruction;    {writes the instructions if it is chosen}
var key : char;
begin
clrscr;
writeln('BOGGLE');
writeln;
writeln;
writeln('In the game of Boggle, players are given three minutes to');
writeln('find all the words they can in a four-by-four grid of letters.');
writeln;
write('The letters are printed in random combinations on sixteen dice, and a new board is ');
writeln('generated by shaking the dice inside a specially-designed holder.');
writeln;
writeln('A legal word is one of at least four letters that can be formed from a');
writeln('sequence of adjacent dice on the board each die being used at most once.');             {awesome instructions}
writeln;
writeln('Note that the letter �Q� does not appear alone on a die face.');
write('To increase its usefulness, it appears together with �U�, and the digram is in  fact');
writeln(' counted as two letters for scoring purposes.');
writeln;
writeln;
writeln('press enter to continue...');
repeat
key := readkey;
until ord(key) = 13;
clrscr;
writeln('Single Player:');
writeln('       when you select single player you start the game immediately');
writeln('       simply type in the word you wish and press enter.');
writeln;
writeln('Cheat:');
writeln('      cheating simply shows the board saved to file with');
writeln('      all possible words shown, for example running 2 games at once');
writeln('      one plays the single player, 2nd shows the cheater');
writeln;
writeln('High Scores:');
writeln('     players who score high in single player save there scores to the high');
writeln('     score table in this table players can view the high scores and the');
writeln('     words and board used to score this.');
writeln;
writeln;
writeln('press enter to return to menu...');
repeat
key := readkey;
until ord(key) = 13;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure initialisewords;    {clears the wordlist, used at the start of every new game}
begin
wordcount := 1;
for count := 1 to 50 do
    wordstore[count] := '';
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure singleplayer;    {calls the procedures needed to play}
begin
clrscr;
points := 0;
initialisewords;              
letters := 0;
words := '                ';
screen;
boardgenerator;  {if this procedure is commented then you can use the same board over and over}
rantoboard;                 {useful for testing}
boardwriter;
inputtimer;
gameover;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure fillsarrays;       {reads the text file that displays the menu}
begin
assign(data,'data/intro.txt');
reset(data);
for count := 1 to 30 do
    readln(data,full[count]);
close(data);
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure printarray;   {prints the text file with the menu picture and makes in interactive}
begin
for count := 1 to 20 do
    writeln(full[count]);
for count := 22 to 30 do
begin
     gotoxy(spot*16+1,15+count-22);
     write(full[count]);
end;
case spot of
     0: begin
        gotoxy(4,19);
        write('Play');           {what is written in the box when you move along the menu}
        end;
     1: begin
        gotoxy(20,19);
        write('Cheat');
        end;
     2: begin
        gotoxy(36,18);
        write(' High');
        gotoxy(36,19);
        write('Scores');
        end;
     3: begin
        gotoxy(52,18);
        write('How To');
        gotoxy(52,19);
        write(' Play');
        end;
     4: begin
        gotoxy(69,18);
        write('Exit');
        end;
     end;
gotoxy(7,24);
writeln(' Press A to go to the left, S to go to the right and Enter to select');
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure spotr(key : integer);
var                   {for menus, this procedure reads keys and increments or decrements spotr}
    high : integer;
begin

a := readkey;
a := upcase(a);
if key = 1 then
   high := 3;
if key = 2 then
   high := 8;
if (a = 'S') or (a = 'Q') then     {key mean up then increments}
   if spot <= high then
      inc(spot);
if a = 'A' then                   {key mean down then decrements}
   if spot >= 1 then
      dec(spot);
if ord(a) = 13 then
   spot := spot +1;
if key = 1 then
   begin                   {refreshing screen}
   clrscr;
   printarray;
   end;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure hs;  {prints highscores}
begin
writeln('    ##  ## ######  ####  ##  ##    ####   ####   ####  #####  ######  ####');
writeln('    ##  ##   ##   ##     ##  ##   ##     ##  ## ##  ## ##  ## ##     ##   ');  
writeln('    ######   ##   ## ### ######    ####  ##     ##  ## #####  ####    ####');  
writeln('    ##  ##   ##   ##  ## ##  ##       ## ##  ## ##  ## ##  ## ##         ##'); 
writeln('    ##  ## ######  ####  ##  ##    ####   ####   ####  ##  ## ######  #### ');
writeln;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure enddisp;   {for highscores and the cheat, makes the screen showing all the words}
begin
clrscr;
writeln('                       All Words');
displaywords;
gotoxy(66,5);
writeln('Playing Board');
boardwriter;
gotoxy(2,24);
writeln('Press anykey to return to the menu...');
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure disphigh;     {writes all the highscores and allowes the user to chose which highscore}
var name : array[0..16] of char;     { that they want to see the words of}
    pos : integer;
begin
clrscr;
hs;
loadhigh;
strpcopy(name,highscores[10-spot].word);
pos := strlen(name);
for count := 1 to 10 do
begin
gotoxy(11,10+count);
writeln(highscores[count].word:20,'.....',highscores[count].reason); {written for every highscore}
end;
gotoxy(27-pos,20-spot);
writeln('>>>');    { the 3 arrows has a changable x value according to length of word}
gotoxy(2,24);
writeln('Press Q to go up, A to go down, Enter to choose and Esc to go back to the menu');
spotr(2);
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure displayhschoice;    {when a user choses a highscore that they want to see}
var filename,name : string;   {this procedure finds the text file with the data and }
    rank : integer;           {writes it to screen}
begin
clrscr;
initialisewords;
rank :=11 - spot;
str(rank,name);
filename := concat('highscore/',name,'.txt');
assign(data, filename);
reset(data);
readln(data, board);
for count := 1 to 50 do
begin
     wordstore[count] := '                ';
     readln(data, wordstore[count]);
end;
enddisp;
readkey;
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure hschoice;  {calls the disp high and displayhschoice procedures}
var exit : boolean;
begin
spot := 9;
repeat
exit := false;
repeat
      disphigh;
until (ord(a) = 13) or (ord(a) = 27);  {if key is enter or escape}
if ord(a) = 13 then
begin
     displayhschoice;    {if enter then you see what the details of the highscore is}
     spot := spot - 1;
end;
until ord(a) = 27;    { if it is escape then you leave the procedure}
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure cheat;     {goes through the dictionary and calls wordcheck for every word}
var counter : longint;
    werd : array[0..15] of char;
    info : text;
begin
initialisewords;
clrscr;
writeln('                    <<<FINDING WORDS>>>');
rantoboard;
assign(info,'dict/new.txt');  {gets the dictionary}
reset(info);
counter := 1;
repeat    {repeat for every word in dictionary}
repeat    {repeats for 50 correct words}
    for count := 0 to 15 do
        werd[count] := ' ';  
    readln(info,werd);  {gets the words}
    letters := strlen(werd); {gets how long the word is}
    wordcheck(werd, false, letters);  {calls wordcheck}
    inc(counter);
until (counter = 44000) or (wordcount = 50);
enddisp;
if wordcount = 50 then
begin
gotoxy(2,24);            {if the procedure finds more than 50 words(array size is 50)}
writeln('Press anykey to view more words...        ');    {clears the array}
readkey;
initialisewords;
end;
until counter = 44000;
readkey;
close(info);
end;

{---------------------------------------------------------------------------------------------------------------------------}

procedure menu(choice : integer);
begin                    {calls the procedure depending on what the user choses}
case choice of
     1: singleplayer;
     2: cheat;
     3: hschoice;
     4: instruction;
     5: donewincrt;
end;
end;

{-----------------------------------------------------------------------------------------------------------------------------}

procedure start;        {callse the menu procedure, and prints the menu}
begin                   {also prevents the program from ending without the user chosing to}
repeat
spot := 0;
clrscr;
fillsarrays;
printarray;
repeat
spotr(1);
until ord(a) = 13;
menu(spot);
until spot = 7;
end;

{----------------------------MAINLINE-------------------------------------------------------}

begin
assign(data,'data/test.txt');
{$I-}
rewrite(data);         {checks that the user has permission to write to files, ie if not admin}
{$I+}                  {then calls the starting procedure}
if ioresult = 0 then
    start
else
begin
    writeln('This Game requires editing of files, if this game is in the resource folder or some');
    writeln('other location where you do not have permission to rewrite files, u will not be able to play');
    writeln('please move to another location, such as your U:/ drive');
    writeln('Press anykey to exit');
    readkey;
    donewincrt;
end;
end.