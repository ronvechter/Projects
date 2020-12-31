/* PSTAT 130 Project */
/* Ron Vechter */



/* Part 1 */
	/* Using the sfosch dataset in Class dataset: */
	/* Variable ‘TotPassCap’ is the total passenger capacity, ‘FClassPass’, ‘BClasspass’ and */
	/*‘EclassPass’ are the # of passengers for each class. */
libname hw3 '/folders/myfolders/ClassDataSets';
data sfo;
	set hw3.sfosch;
run;
proc sort data=sfo out=pass;
	by date;
run;
proc print data=pass;
run;
		/* a) calculate a total number of passengers for each day using a sum statement */
data pass1;
	set pass;
	by date;
	if first.date then total=0;
	total + FClassPass;
	total + BClassPass;
	total + EClassPass;
	if last.date;
run;
		/* b) using the total number of passengers to calculate the percentage of total passenger */
		/*  capacity for each day. */
data pass2;
	set pass;
	by date;
	if first.date then capacity=0;
	capacity + TotPassCap;
	if last.date;
run;

data pass3;
	set pass1;
	set pass2;
run;
data pass4;
	set pass3;
	percentage = total/capacity;
run;
		/* c) print the result total passengers, total capacity and percentage for each day, percentage */
		/*  with a percent format, like 90.85%; */
proc print data=pass4;
	var date total capacity percentage;
	format percentage percent10.2;
run;
		/* d) are there any days reported as being over capacity? */
/* We see that there is one day, December 28, 2000, that is over capacity, at 110.50%. */
/* We have 263 total passengers, with the total passenger capacity being 238. */







/* Part 2 */
	/* First, we want to create the data sets that read each file with name and course name variables */
data POLI125;
	infile '/folders/myfolders/ClassDataSets/POLI125.txt';
	input StudentName $1-16;
	CourseName = 'POLI125';
run;

data PSTAT130;
	infile '/folders/myfolders/ClassDataSets/PSTAT130.txt';
	input StudentName $1-16;
	CourseName = 'PSTAT130';
run;

data PSYCH118;
	infile '/folders/myfolders/ClassDataSets/PSYCH118.txt';
	input StudentName$1-16;
	CourseName = 'PSYCH118';
run;

	/* Then we want to combine the data sets for all students */
data allstudents;
	length CourseName $8;
	set POLI125 PSTAT130 PSYCH118;
run;

	/* Then we want to create data sets for instructor and classroom */
data instructors;
	infile '/folders/myfolders/ClassDataSets/instructors.txt';
	input @1 InstructorName $14. @16 AcademicRank $5. @23 Salary dollar7. @32 CourseName $8. @42 FirstClassDate mmddyy8.;
run;
data classrooms;
	infile '/folders/myfolders/ClassDataSets/classrooms.txt';
	input @1 BldgName $12. @14 RoomNumber 4. @19 CourseName $8. @29 Days $5. @36 Time time8.;
run;

	/* Combine the instructor, classrooms and allstudent data sets so that each student */
	/* is paired with his/her instructor and the room information for that class */
proc sort data=instructors;
	by CourseName;
run;
proc sort data=classrooms;
	by CourseName;
run;
proc sort data=allstudents;
	by CourseName;
run;

data class_info;
	merge instructors classrooms allstudents;
	by CourseName;
run;

proc print data=class_info;
	format Salary dollar10. FirstClassDate mmddyy8. Time timeampm8.;
run;

	/* creating a 'Roster' for each class showing the names of students taking the class */
proc format;
	value $arank 'Asst' = 'Assistant Professor'
			'Assoc' = 'Associate Professor';
run;

data course_info;
	set class_info;
	label InstructorName = 'Instructor Name'
		AcademicRanks = 'Academic Rank'
		CourseName = 'Course Name'
		StudentName = 'Student Name'
		FirstClassDate = 'First Class Date'
		BldgName = 'Building Name'
		RoomNumber = 'Room Number'
		Days = 'Class Days'
		Time = 'Class Time';
	format Salary dollar10. FirstClassDate mmddyy8. Time timeampm8. AcademicRank $arank.;
run;

proc print data=course_info;
	var StudentName;
	by CourseName;
	pageby CourseName;
run;

	/* Creating a class list for each student */
proc sort data=course_info;
	by StudentName;
run;

proc print data=course_info noobs label;
	by StudentName;
	var CourseName FirstClassDate InstructorName BldgName RoomNumber Days Time;
run;

	/* Master list of all students whose instructor is an Associate Proffesor */
title 'List of all Students whose instructor is an Associate Professor';
proc print data=course_info noobs label;
	where AcademicRank = 'Assoc';
	var StudentName CourseName InstructorName AcademicRank Salary;
run;
title;