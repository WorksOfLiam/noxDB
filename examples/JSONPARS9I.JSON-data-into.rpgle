**FREE
// ------------------------------------------------------------- *
// noxDB - Not only XML. JSON, SQL and XML made easy for RPG

// Company . . . : System & Method A/S - Sitemule
// Design  . . . : Niels Liisberg

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

// Look at the header source file "QRPGLEREF" member "NOXDB"
// for a complete description of the functionality

// When using noxDB you need two things:
//  A: Bind you program with "NOXDB" Bind directory
//  B: Include the noxDB prototypes from QRPGLEREF member NOXDB

// Using the "data-into"

// ------------------------------------------------------------- *
Ctl-Opt BndDir('NOXDB') dftactgrp(*NO) ACTGRP('QILE');
/include qrpgleRef,noxdb

    example1();
    example2();
    *INLR = *ON;

// ------------------------------------------------------------------------------------
// Parse a string put into a datastructure 
// ------------------------------------------------------------------------------------
dcl-proc example1;


    // This is he data structure we map the object graph into:
    // The name "rows" is in the data-into statement
    // The "dim" causes it to be an array: 
    dcl-DS rows dim(100) qualified inz;
        id   int(10);
        name varchar(256);
    end-ds;  

    dcl-s pJson      pointer;
    dcl-s i	         int(10);    

    // Set the delimiters used to access the graph selector
    json_setDelimiters ('/\@[] .{}''"$');

    // This is our array of objects:
    pJson = json_ParseString(   
        '[                             -
            {"id":1,"name":"John"},    -
            {"id":2,"name":"Doe"}     -     
        ]'
    );     

    // Now the magic: the pJson object graph is send to the mapper
    data-into rows %data('':'ccsid=job') %parser(json_DataInto(pJson));
    
    // Now we can use it from data structures:
    for i = 1 to %elem(rows) ;
        if rows(i).id = 0;
            leave;
        endif;
        json_joblog(%char(rows(i).name));
    endfor;                                                           

    // Always remember to delete used memory !!
    json_delete(pJson);

end-proc;
// ------------------------------------------------------------------------------------
// Get a resultset and place it into a row structure - row by row
// ------------------------------------------------------------------------------------
dcl-proc example2;


    // This is he data structure we map the object graph into:
    // The name "rows" is in the data-into statement
    // The "dim" causes it to be an array: 
    dcl-ds qcustcdt  extname('QIWS/QCUSTCDT') qualified inz  end-ds;
    dcl-ds list      likeds(json_iterator);
    dcl-s  pJson     pointer;
    dcl-s  i	     int(10);    

    // Set the delimiters used to access the graph selector
    json_setDelimiters ('/\@[] .{}''"$');

    pJson = json_sqlResultSet ('Select * from qiws.qcustcdt');

    list = json_setIterator(pJson);
    dow  json_ForEach(list);
        // Now the magic: the pJson object graph is send to the mapper
        data-into qcustcdt %data('':'ccsid=job') %parser(json_DataInto(list.this));
    enddo;

    // Always remember to delete used memory !!
    json_delete(pJson);

end-proc;
