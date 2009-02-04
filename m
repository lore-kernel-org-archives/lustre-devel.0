From: Colin Ngam <Colin.Ngam@Sun.COM>
Date: Tue, 03 Feb 2009 19:29:05 -0600
Subject: [Lustre-devel] Lustre HSM - some talking points.
In-Reply-To: <4988E42E.2000803@sun.com>
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
Message-ID: <3F93D192-9058-4393-8D78-B5E775F702B1@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Feb 3, 2009, at 6:41 PM, Nathaniel Rutman wrote:

Hi,

If these are all agreeable, lets start drawing up the Spec.

> Colin Ngam wrote:
>
> Is OSAM available on Linux?

Can be access from a Linux Client.   It is another file system type to  
SAMQFS.  We have inserted software restrictions to prevent it from  
being used as a Shared QFS file system type.  This is one of those,  
code is there, needs testing.  I did the code so ...

Keep in mind that the Meta Data Server is still only Solaris.

>
>
> Object SAMQFS - HSM for Lustre
> ------------------------------
>
> 0.  We re basically looking at the HSM as a Repository right?
>
>   yes
>
>
> 2.  Object SAMQFS meta data(inodes) is used as a database for files  
> that are
> archived etc.
>
>   You mean, store the Lustre metadata attributes in these inodes?  Or
>   rather that these inodes just keep track of the objects in the
>   archive (like block pointers)
Inodes on the OSAM nodes are for managing the files in archive and the  
link to Lustre.  I expect to store Lustre Meta Data as EA in tar  
file.  I am assuming that we do not need Lustre Meta data on disk  
cache.  Lustre already has it in Lustre .. only need to access these  
for Ultimate Disaster Recovery from tape.
>
>
> 3.  This database can be dumped and restored really quick using  
> normal meta
> data backup of the HSM.  The inodes are kept in 1 file.  This is not  
> a Lustre
> dump but rather a dump of Object SAMQFS.  No file data dump is  
> required.  Files
> not archived yet are irrelevent ..  Incrementals can be obtained by  
> comparing
> 2 full dumps and just keeping the diffs.  Persistent Object SAMQFS  
> file id
> can be preserved if we restore a complete version of the dump.   
> Otherwise,
> it can be different.  We can update Lustre with the new file id for  
> the given
> Lustre File ID.  Consider this error recovery path ..
>
>   If we're already storing archive-specific opaque data (the SamFID),
>   I see no reason why we couldn't allow the archive to modify that
>   value at will.  We'd need to put a lock around it...
Yes we can.  It is just a matter of how do we initiate this change  
between the archive and Lustre.
>
>
>
> 4.  Object SAMQFS should have very simple policies - archive  
> immediate, number
> of copies and when copies to be made etc..  This can actually be  
> passed by
> Lustre and executed by Object SAMQFS.  Last thing we want to do is  
> to have to
> configure 2 Policy engines.
>
>   I was envisioning the Lustre "action list" as a list of files and
>   actions.  The actions could be semi-complex (e.g. "archive at level
>   4") which would mean something to the archive.
Yes, this needs to be defined.  This should include future action like  
"made 2nd copy after 24 hours etc.  SAMQFS has a standard set of  
Policies .. if you want to deviate we will have to provide new code.

We need to define these actions.
>
>
>
> 5.  Lustre will store a 16 Bytes Object SAMQFS identifier.  A 8  
> bytes unique
> file system ID and a 8 bytes Object SAMQFS File ID.  An Object  
> SAMQFS can only
> support 32 bits number of files.  This will be less if we use inodes  
> for
> extended attributes etc.  The file system ID will allow us to create  
> multiple
> Object SAMQFS "mat" file system - provide infinite number of files  
> that can
> be supported.
>
>   Do separate filesystems need separate disks?  This opens up a
>   inodecount/filesize relation, or we have to create new OSAM
>   filesystems on demand (ENOSPC, create new fs, store file -- hmm, not
>   so hard).
No, a file system is configured using slices/partitions.  More than 1  
FS can reside on the same disk.  There will not be any inodecount/ 
filesize relationship because on the SAMQFS node we will release file  
data space as needed after the file is on Tape.  We also do the "punch".

Yes FS can be created on demand.
>
>
>
> 6.  No namepace.  Lustre pathnames can be stored as Extended
> Attributes.
>
>   No problem except for the disaster recovery scenario.  And even in
>   that case we don't need EAs if we're storing mini-tarballs already -
>   just add an empty file to the tarball with the actual filename.
OK.
>
>
>
> 7.  Files to be archived and staged in together(associative  
> archiving) to be
> given in a list by Lustre.  Object SAMQFS will figure out a way to  
> link these
> files together and put them on the same tarball - this is not for  
> free.
>
>   It's actually not clear that this is useful for Lustre.  If the
>   point of Lustre HSM is to extend the filesystem space, it makes
>   little sense to bother archiving small files.  Anyhow, this can be a
>   future optimization.
Lustre's call.
>
>
>
>
> Basic Object SAMQFS - HSM for Lustre Archive Events
> -------------------------------------------
>
> Lustre calls with the following Information:
>
> 1.  Luster FID
> 2.  Luster Opaque Meta Data
> 3.  Luster Tar File required Data e.g. Path Name
> 4.  Luster Archiving Policy for this file - must be simple.
>
> Lustre gets back:
>
> 1.  Object SAMQFS Identifier.
>
> Depending on asynchronous or synchronous archiving:
>
> 1.  Lustre can status with the given "Object SAMQFS Identifier"
>
>   Sounds fine.  Lustre will always use asynchronous archiving, as far
>   as I can see.
Okay.
>
>
>
>
> Basic Object SAMQFS - HSM for Lustre Stage In Events(bring data back)
> ---------------------------------------------------------------------
>
> 1.  Lustre just reads the file with the given "Object SAMQFS  
> Identifier"
>
>
> Basic Object SAMQFS - HSM for Lustre status Events(check state)
>
> 1.  Lustre perform "sls" command on Object SAMQFS Client.
>
> PS - We can have both User level command and API capabilities.
>
>   well technically, Lustre calls with the following information
>   1.  Luster FID
>   2.  Luster Opaque Meta Data
>   (BTW, that's Lustre, not Luster)
>   OSAM ignores fid and just uses OSAM identifier

Right, Fiber/Fibre :-)

I am missing something here .. Stage-In is to get a file from  
archive .. why do we need Item 2?  Or is 2 OSAM Identifier?  If so,  
great.  I like it.

In this case, we should trust Lustre FID.  The OSAM ID is for a very  
fast search - direct index.

>
>
>
>
> Basic Object SAMQFS - HSM for Lustre Delete Event
> -------------------------------------------------
>
> 1.  Lustre can effectively do an "rm" on the Object SAMQFS  
> Identifier or
> calls an API.
>
>
> Object SAMQFS Dump and Restore
> ------------------------------
>
> Independent Administrative event.
>
> Lustre Dump and Restore
> -----------------------
>
> Can be an Independent Lustre event.
> However, this does have impact on when we can actually delete a file  
> from
> tape if a Lustre Dump has a reference to this file e.g.
> 1.  Archive file.
> 2.  Dump Lustre.
> 3.  Delete file.
>
> Now you want to restore the deleted file.
>
>   Dumping the Lustre metadata isn't something we've really talked
>   about before - or, rather, the restore part isn't :)
>   Effectively, the Lustre metadata is (all the data on) the entire MDT
>   disk.  I'm not sure it makes any sense to try to be any more
>   elaborate than that, but maybe.  It would be nice to be able to e.g.
>   dump the disk to a regular (big!) file store in OSAM, so we've got
>   everything on 1 set of tapes...
Lustre's call.
>
>
>
>
> Ultimate Disaster Recovery - Directly from Tapes
> ------------------------------------------------
>
> Requires Tar File to be complete with Lustre Meta Data.
> Since this is a recreation of both the Lustre FS and Object SAMQFS  
> "mat" FS
> I would be incline to believe that at a minimum, we will not require  
> the
> Object SAMQFS identifier to be persistent from previous  
> incantation.  I am also
> incline to believe that if you take regular Object SAMQFS dumps,  
> both full and
> also incrementals and store this safely on tape - you may not need  
> this
> procedure .. but then, that's why we call it Ultimate Recovery.
>
>   If everything is wiped out except the tapes, we would just
>   repopulate a new Lustre fs anyhow. Once the OSAM fs is regenerated,
>   we walk all the objects and create object placeholders in the new
>   Lustre fs referencing the new OSAM fids and marking everything as
>   punched.  As users start using files they are pulled back in
>   automatically.
Yes.  The chances of both a Lustre and OSAM collapse at the same time  
is not very good.
>
>
>
>
> Syncing Object SAMQFS with Lustre
> ---------------------------------
>
> Lustre File Identifier and Object SAMQFS Identifier can get out of  
> sync - shit
> happens.  We need syncing capabilities.
>
>   Only if we stored enough information to mismatch :)  If Lustre asks
>   for a FID, and it gets back the wrong file, it doesn't / can't
>   know.  Unless we store the FID inside the file it gets back and we
>   verify it.
If you always call with Lustre ID and OSAM ID, if we find that the  
Lustre ID does not match the OSAM ID, because perhaps we have done  
OSAM recovery and we are using a different OSAM ID to hold the Lustre  
ID now, we can search for the inode that match the Lustre ID, fetch  
the file and also update Lustre with the new OSAM ID.

>
>
>
> Object SAMQFS - Freeing space on tapes
> --------------------------------------
>
> We will need a way to determine with Lustre - conclusively that an  
> archive is
> no longer needed.
>
>   If Lustre policy manager says "rm", then Lustre has no way to ever
>   get that file back.  There's no time-machine like old versions of
>   directories.  Would be a cool feature though.  Maybe archive says
>   "ok" to the rm, but secretly holds on to the file for some time in a
>   special "recently deleted" dir?
No namespace - no dir.

If Lustre removes the file, we can delay the scrub.  If Lustre can  
come back with the Lustre ID and OSAM ID, if it has not been scrubbed,  
you can get it back.

Thanks.

colin
>
>
>
>
