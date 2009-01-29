From: Vicky White <vyw@ornl.gov>
Date: Thu, 29 Jan 2009 10:35:01 -0500
Subject: [Lustre-devel] SAM-QFS, ADM, and Lustre HSM
In-Reply-To: <4980C06D.3000309@ornl.gov>
References: <D262D095-D17F-4119-B908-FBE502201835@Sun.COM>
	<49480788.7080306@sun.com>
	<FCBC9AEA-C61C-4EEA-847B-FE283D19A7BF@Sun.COM>
	<05e901c95fba$f7688df0$e639a9d0$@com> <49481EEF.2010802@sun.com>
	<EB7E4462-1CFF-4CCD-A38F-AE4D89108B59@Sun.COM>
	<3DF0F4AF-F4D6-476E-98F7-CD912C49FC18@Sun.COM>
	<2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com>
	<4977E5BD.7000706@sun.com> <4978DB1E.30507@sun.com>
	<9365C284-E805-46B6-95B2-226C1E2ED112@Sun.COM>
	<4980C06D.3000309@ornl.gov>
Message-ID: <4981CCA5.6070005@ornl.gov>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


>> Looks like HPSS will support EA in 7.1.2.0, June 2009
>> I have asked Vicky here at ORNL to dig a bit into what the EA 
>> features will look like.   
>
> The last draft of this design I saw was from November.    Work on this 
> is picking up right now and has been bumped to a high priority, due 
> for release this June, as Galen says.   I am trying to find out if 
> there is a later design and how much about it I can share.


There is a more recent draft, though the main change seems to be change 
the name from "Extended Attributes" to "User Defined Attributes" (UDAs).

The gist of the current draft is that a new database table would be 
added to the HPSS schema which would consist of two columns, an object 
ID and an XML document.   The XML document would define all the UDAs for 
some HPSS name space object (file, directory, symlink, hard link, etc.) 
in some key/value format.   It would take advantage of the new 
capability in version 9 of DB2 of handling XML columns and being able to 
index and query them as XML, not just as a text string.   The object ID 
column of the new table would hold the ID of the HPSS name space object  
to which the extended attribute(s) apply.

The design is intended to handle small UDAs, up to 512 bytes in length 
for the total XML document, in order to be able to store the data in the 
same row; larger documents will be accepted but would have to be stored 
in a large object (LOB) area external to the main table, reducing 
efficiency.   This is something to keep in mind if we start talking 
about putting full (or even relative) pathnames in as UDAs.

I understand that the CEA folks have a copy of this draft of the design 
and are in communication with its authors.

Vicky
