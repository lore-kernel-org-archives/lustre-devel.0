From: Nathaniel Rutman <Nathan.Rutman@sun.com>
Date: Mon, 09 Feb 2009 16:48:52 -0800
Subject: [Lustre-devel] Lustre HSM - some talking points.
In-Reply-To: <3F93D192-9058-4393-8D78-B5E775F702B1@Sun.COM>
References: <3DF0F4AF-F4D6-476E-98F7-CD912C49FC18@Sun.COM>
	<2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com>
	<4977E5BD.7000706@sun.com> <4978DB1E.30507@sun.com>
	<497A144C.4000408@Sun.COM>
	<20090126193548.GF3652@webber.adilger.int> <497E35A3.3080603@sun.com>
	<DEB5E509-4641-40B6-86CA-972D885975D3@Sun.COM>
	<4983998D.1030601@sun.com>
	<8585251D-41D7-4B42-99F9-BDBFA2CF88C1@Sun.COM> <4987098F.402@Sun.COM>
	<367E32B4-A759-45AD-9D2C-48C051FE1D62@Sun.COM>
	<49872C9B.7060708@Sun.COM> <4988E42E.2000803@sun.com>
	<3F93D192-9058-4393-8D78-B5E775F702B1@Sun.COM>
Message-ID: <4990CEF4.7040707@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Colin Ngam wrote:
> If these are all agreeable, lets start drawing up the Spec.
>
sure

>> Basic Object SAMQFS - HSM for Lustre status Events(check state)
>>
>> 1.  Lustre perform "sls" command on Object SAMQFS Client.
>>
>> PS - We can have both User level command and API capabilities.
>>
>>   well technically, Lustre calls with the following information
>>   1.  Luster FID
>>   2.  Luster Opaque Meta Data
>>   (BTW, that's Lustre, not Luster)
>>   OSAM ignores fid and just uses OSAM identifier
>
> Right, Fiber/Fibre :-)
>
> I am missing something here .. Stage-In is to get a file from archive 
> .. why do we need Item 2?  Or is 2 OSAM Identifier?  If so, great.  I 
> like it.
Yes, item 2 is archive-specific (e.g. OSAM) identifier.
>
> In this case, we should trust Lustre FID.  The OSAM ID is for a very 
> fast search - direct index.
Agreed, the Lustre FID will be the authoritative value.  OSAM would 
internally use the OSAM identifier for the fast lookup, then verify the 
Lustre FID matches.  If not, we would have to do a slow search for the 
Lustre FID...
>> Syncing Object SAMQFS with Lustre
>> ---------------------------------
>>
>> Lustre File Identifier and Object SAMQFS Identifier can get out of 
>> sync - shit
>> happens.  We need syncing capabilities.
>>
>>   Only if we stored enough information to mismatch :)  If Lustre asks
>>   for a FID, and it gets back the wrong file, it doesn't / can't
>>   know.  Unless we store the FID inside the file it gets back and we
>>   verify it.
> If you always call with Lustre ID and OSAM ID, if we find that the 
> Lustre ID does not match the OSAM ID, because perhaps we have done 
> OSAM recovery and we are using a different OSAM ID to hold the Lustre 
> ID now, we can search for the inode that match the Lustre ID, fetch 
> the file and also update Lustre with the new OSAM ID.
Perfect.  We will also need a way of modifying the Lustre FID stored in 
the archive for the ultimate disaster recovery, which is equivalent to 
"pre-populating" a Lustre FS with files from the archive.  We create an 
empty file, mark it as "in archive", add the OSAM fid, and need to set 
the archive's Lustre FID to match the new empty file.

>
>>
>>
>>
>> Object SAMQFS - Freeing space on tapes
>> --------------------------------------
>>
>> We will need a way to determine with Lustre - conclusively that an 
>> archive is
>> no longer needed.
>>
>>   If Lustre policy manager says "rm", then Lustre has no way to ever
>>   get that file back.  There's no time-machine like old versions of
>>   directories.  Would be a cool feature though.  Maybe archive says
>>   "ok" to the rm, but secretly holds on to the file for some time in a
>>   special "recently deleted" dir?
> No namespace - no dir.
>
> If Lustre removes the file, we can delay the scrub.  If Lustre can 
> come back with the Lustre ID and OSAM ID, if it has not been scrubbed, 
> you can get it back.
>
Let's not worry about this for V1.  Once a file is rm'ed from Lustre, no 
way to get back Lustre ID or OSAM ID.
