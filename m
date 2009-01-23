From: Harriet G. Coverston <Harriet.Coverston@Sun.COM>
Date: Fri, 23 Jan 2009 10:46:24 -0600
Subject: [Lustre-devel] SAM-QFS, ADM, and Lustre HSM
In-Reply-To: <4978DB1E.30507@sun.com>
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
Message-ID: <9365C284-E805-46B6-95B2-226C1E2ED112@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathan,
On Jan 22, 2009, at 2:46 PM, Nathaniel Rutman wrote:
>>>
>>> Integration with SAM-QFS
>>> The SAM policy engine is tightly tied directly to the QFS  
>>> filesystem and for this reason it is not possible to replace the  
>>> HPSS policy engine with SAM.  However, SAM policies could be  
>>> layered in at the copytool level.  The split as we envision it is  
>>> this: existing Lustre policy engine decides which and when files  
>>> should be archived and punched, and SAM-QFS decides how and where  
>>> to archive them. The copytool in this case
>>
>> SAM-QFS already does all these, i.e,  "how and where".
> Yes.  SAM policies would likely have to be written without reference  
> to specific filenames/directories, since that info will not be  
> readily available.  If this proves to be performance-limiting (maybe  
> certain file extensions (.mpg) should be stored in a different  
> manner than another (.txt)), then we can probably find a way to pass  
> the full pathname through to SAM, but this would require SAM code  
> changes.
SAM supports classification policy rules for files  -- (1) number of  
copies, up to 4 (2) where to put the copies  on which vsn pools  -  
disk and/or tape, local and/or remote) (3) when to make the copies  
(time based archiving). You specify the policy in the archiver.cmd  
file. You can group files for a policy rule by pathname, owner, group,  
size, wildcard, and access time.
>
>>
>>> is simply the unix "cp" command (or perhaps tar as mentioned  
>>> above), that copies the file from the Lustre mount point to the  
>>> QFS mount point on one (of many) clients that has both filesystems  
>>> mounted.  SAM-QFS's file staging and small-file aggregation (as  
>>> well as parallel operation) would all be used "out of the box" to  
>>> provide the best performance possible.
>>
>> The one thing that should be taken into account is that the files  
>> being
>> moved from Lustre to SAM are losing the "age" information.  This  
>> might
>> cause SAM some heartburn because all of the files being added will be
>> considered "new" but there will be a large enough influx of files  
>> that
>> it will need to archive and purge files within hours.

>>
>>
>> It may be that the SAM copytool will need to be modified to allow it
>> to pass on some "age" information (if that is something other than
>> atime and mtime) so the SAM policy engine can treat these files  
>> sensibly.
>> Alternately, it may be that the SAM copytool will need to be smart  
>> enough
>> to mark the new files as "archive & purge immediately" in some  
>> manner.
There is a option to release files from the disk cache after all  
archive copies have been made. You may want to set this in the  
archiver.cmd file. The releasing is done automatically. It depends on  
how you are going to use SAM. If it is just for backup, then, yes, set  
this. However in your mail above, you also are managing your disk  
cache. In this case, it will be faster to retrieve files that are in  
our disk cache.

This brings up the question of restore. In case of a Lustre disk  
failure, how are you going to restore
your Lustre file system?
>>
>>
> We will just use cp -a to preserve timestamps, ownership, perms etc;  
> I don't see what any additional age info could be.  As to the  
> heartburn problem, QFS has disk cache as the first level of archive;  
> as that fills files are moved off to secondary automatically.  We  
> can adjust these watermarks to aggressively move files off to tape.   
> If something backs up, the cp command will simply block.  It would  
> be nice to have some visibility when this situation occurs, but in  
> fact it's not at all clear what we should do besides change our  
> archiving policy.  This is a general issue, not QFS specific.
You will want to set your disk cache thresholds based on the rate of  
influx of data into the disk cache. We default to high 80%, low 70%  
which means when the disk cache reaches 80%, we release the oldest  
archived files until the disk caches reaches 70%. Some of our oil  
customers set the theshold to 60% - 50% because of the heavy influx.  
Of course, if SAM does reach 100%, we block the writers until we have  
space so this is transparent to the application.
>
>
>> Again, SAM-QFS already does all of these. Correct?
>> So no code changes are expected at SAM-QFS side, right?
> Correct.  As I see it today, no SAM-QFS code changes are necessary,  
> and the QFS copytool will likely be identical or almost identical to  
> the HPSS copytool.
Agree. I don't see any SAM-QFS code changes required. The Lustre  
copytool will write to HPSS using the HPSS APIs and write to SAM-QFS  
with a ftp or pftp interface. This is minimum changes.
>
>>
>> For Lustre/SAM-QFS integration, could you point out specifically
>> which area (in this write-up) can be done by U.Minn students?
> I don't actually see any work to be done at this point.  There's the  
> pathname pass-through potential, but I'm not convinced it's at all  
> necessary.
I do see work to switch the HPSS APIs to ftp or pftp. If this is  
already supported by HPSS, then, yes, no changes are required.

    - Harriet

Harriet G. Coverston
Solaris, Storage Software			 |  Email: harriet.coverston at sun.com
Sun Microsystems, Inc.                     	 |  AT&T:  651-554-1515
1270 Eagan Industrial Rd., Suite 160       |  Fax:   651-554-1540
Eagan, MN 55121-1231
