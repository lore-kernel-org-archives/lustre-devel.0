From: Rick Matthews <Richard.Matthews@Sun.COM>
Date: Fri, 23 Jan 2009 13:02:36 -0600
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
Message-ID: <497A144C.4000408@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nathaniel and all,
  Thanks for putting this together.

  Having a mover to put data into QFS is a great idea, and can easily 
use the QFS Linux client. I don't think
you would necessarily get QFS policy for native Lustre files unless the 
"moved" files retained the Lustre attributes,
from which you want policy decisions made. There may be ways to do this. 
You would automatically gain the
file gathering of QFS and its efficient tape handling. I also think 
there is a "archive then release (purge)"
policy that can be established. The applicable Lustre namespace would be 
essentially duplicated in the
QFS space, and (I think) QFS classification and policy occur on that 
name space. Doing so gives you
access to rich QFS policy. This also allows QFS to migrate data to/from 
archive media without I/O or
compute load on any Linux clients.

Nathaniel Rutman wrote:
> (adding lustre-devel, dropping Bojanic from distro list; if anyone 
> else wants off, let me know.)
>
> Hua Huang and Andreas wrote:
>>
>> Nathan,
>>
>> Thanks for the write-up.  A few questions and comments.
>>
>> SAM-QFS only runs on Solaris,  so it is always
>> remotely mounted on Lustre client via network connection,
>> right?
> QFS has a Linux native client 
> (http://www.sun.com/download/products.xml?id=4429c1d1).
> So the copy nodes would be linux nodes acting as clients for both 
> Lustre and QFS.  This would generally result in two network hops for 
> the data, but by placing the clients on OST nodes and having the 
> coordinator choose wisely, we can probably save one of the network 
> hops most of the time.  This may or may not be a good idea, depending 
> on the load imposed on the OST.  The copytool would also require us to 
> pump the data from kernel to userspace and back, potentially resulting 
> in significant bus loading.  We could memory map the Lustre side
>
>>
>>
>> Nathaniel Rutman wrote:
>>> Hi all -
>>> So we all have a common starting point, I'm going to jump right in 
>>> and describe the current plan for integrating Lustre's HSM feature 
>>> (in development) with SAM-QFS and ADM.
>>>
>>> HSM for Lustre can be broken into two major components, both of 
>>> which will live in userspace: the policy engine, which decides when 
>>> files are archived (copy to (logical) tape), punched (removed from 
>>> OSTs), or deleted; and the copytool, which moves file data to and 
>>> from tape.  A third component that we call the coordinator lives in 
>>> kernel space and is responsible for relaying HSM requests to various 
>>> client nodes.
>> s/tape/the archive/ 
> yes, I knew my "(logical) tape" statement needed to be clarified :)
>>
>>>
>>> The policy engine collects filesystem info, maintains a database of 
>>> files it is interested in, and makes archive and punch decisions 
>>> that are then communicated back to Lustre.  Note that the database 
>>> is only used to make policy decisions, and is specifically _not_ a 
>>> database of file/storage location information.  Periodically, the 
>>> policy engine give a list of file identifiers and operations (via 
>>> the coordinator) to any number of Lustre clients running copytools.
>> This work will be done by CEA as part of the HPSS HSM solution.
>> This work is generic in the sense that it could be SAM-QFS or any
>> other tape backend on the remote side for archival, right?
> Yes.  The issue here is that the policy engine is a big part of 
> "brains" of the HSM, and could be a key differentiator for customers.  
> That's why the ADM integration would likely replace the HPSS policy 
> engine with ADM's Event Manager -- presumably we'll be able to get 
> enhanced features by doing this.  The actual benefits need to be 
> investigated.
>> Is it expected that a given copytool would be given multiple files to
>> archive at one time?  This would allow optimizing the archiving 
>> operations
>> to e.g. aggregate small files into a single archive object, but would
>> make identifying and extracting these files from the aggregate harder.
>>   
> I do expect the coordinator to hand a list of files to each 
> copytool.   But SAM-QFS would actually handle small file aggregation 
> "underneath" the copytool itself; we don't have to worry about 
> identification/extraction.
>
>>> The copytool will take the list of files and perform the requested 
>>> operation: archive, delete, or restore.  (It is potentially possible 
>>> to have finer-grained archive commands passed from the policy 
>>> engine, e.g. archive_level_3.)  It will then copy the files off to 
>>> tape/storage using whatever hardware/software specific commands are 
>>> necessary.  Note that the file identifiers are opaque 16-byte 
>>> strings.  Files are requested using the same identifiers; "paths may 
>>> change, but the fids remain the same" is the basic philosophy.  The 
>>> copytool may hash the fids into dirs/subdirs to relieve problems 
>>> with a flat namespace, but this is invisible to Lustre.  Having said 
>>> that, additional information such as the full path name, EAs, etc. 
>>> may be added by the copytool (using a tar wrapper, for example), for 
>>> disaster recovery or striping recovery.
>>> The initial version of the copytool and policy engine will be 
>>> written targeted for HPSS, but it is likely that the SAM-QFS 
>>> integration will use the same pieces.  Perhaps calling it the 
>>> "Lustre policy engine" would be more appropriate.
>>
>> So the initial version will be done by CEA as part of the HPSS.
> Part of the "HPSS-compatible Lustre HSM solution", which is our 
> initial target, yes.
>>
>> You mentioned other details above, which can be SAM_QFS specific?
>> I am trying to figure out if the full-version of copy-tool used in
>> Lustre/SAM_QFS integration will be implemented specifically for SAM-QFS
>> from the Lustre side.
> There are two items that I can think of that may be archive-specific
> 1. hash the fids into dirs/subdirs to avoid a big flat namespace
> 2. inclusion of file extended attributes (EAs)
> But in fact, I don't know enough about HPSS to say we don't need these 
> items anyhow.  CEA, can you comment?
> I think current versions of HPSS are able to store EAs automatically, 
> and QFS is not, so that may be one difference.
>>
>>>
>>> Integration with SAM-QFS
>>> The SAM policy engine is tightly tied directly to the QFS filesystem 
>>> and for this reason it is not possible to replace the HPSS policy 
>>> engine with SAM.  However, SAM policies could be layered in at the 
>>> copytool level.  The split as we envision it is this: existing 
>>> Lustre policy engine decides which and when files should be archived 
>>> and punched, and SAM-QFS decides how and where to archive them. The 
>>> copytool in this case 
>>
>> SAM-QFS already does all these, i.e,  "how and where".
> Yes.  SAM policies would likely have to be written without reference 
> to specific filenames/directories, since that info will not be readily 
> available.  If this proves to be performance-limiting (maybe certain 
> file extensions (.mpg) should be stored in a different manner than 
> another (.txt)), then we can probably find a way to pass the full 
> pathname through to SAM, but this would require SAM code changes.
>>
>>> is simply the unix "cp" command (or perhaps tar as mentioned above), 
>>> that copies the file from the Lustre mount point to the QFS mount 
>>> point on one (of many) clients that has both filesystems mounted.  
>>> SAM-QFS's file staging and small-file aggregation (as well as 
>>> parallel operation) would all be used "out of the box" to provide 
>>> the best performance possible.
>>
>> The one thing that should be taken into account is that the files being
>> moved from Lustre to SAM are losing the "age" information.  This might
>> cause SAM some heartburn because all of the files being added will be
>> considered "new" but there will be a large enough influx of files that
>> it will need to archive and purge files within hours.
>>
>> It may be that the SAM copytool will need to be modified to allow it
>> to pass on some "age" information (if that is something other than
>> atime and mtime) so the SAM policy engine can treat these files 
>> sensibly.
>> Alternately, it may be that the SAM copytool will need to be smart 
>> enough
>> to mark the new files as "archive & purge immediately" in some manner.
>>   
> We will just use cp -a to preserve timestamps, ownership, perms etc; I 
> don't see what any additional age info could be.  As to the heartburn 
> problem, QFS has disk cache as the first level of archive; as that 
> fills files are moved off to secondary automatically.  We can adjust 
> these watermarks to aggressively move files off to tape.  If something 
> backs up, the cp command will simply block.  It would be nice to have 
> some visibility when this situation occurs, but in fact it's not at 
> all clear what we should do besides change our archiving policy.  This 
> is a general issue, not QFS specific.
>
>> Again, SAM-QFS already does all of these. Correct?
>> So no code changes are expected at SAM-QFS side, right?
> Correct.  As I see it today, no SAM-QFS code changes are necessary, 
> and the QFS copytool will likely be identical or almost identical to 
> the HPSS copytool.
>>
>> For Lustre/SAM-QFS integration, could you point out specifically
>> which area (in this write-up) can be done by U.Minn students? 
> I don't actually see any work to be done at this point.  There's the 
> pathname pass-through potential, but I'm not convinced it's at all 
> necessary.
>>
>>>
>>> Integration with ADM
>>> ADM's event manager would replace the HPSS policy engine.  It would 
>>> need some minor modifications to be integrated with the Lustre 
>>> changelogs (instead of DMAPI) and ioctl interface to the 
>>> coordinator.  It also produces a similar list of files and actions.  
>>> The ADM core would be the copytool, consuming the list and sending 
>>> files to tape.  We would also need a bit of work to pass 
>>> communications between ADM's Archive Information Manager and the 
>>> policy engine and copytools.  ADM integration is dependent upon 
>>> having a Linux ADM implementation, or a Solaris Lustre 
>>> implementation (potentially Lustre client only).
>>>
>>> Feel free to question, correct, criticize.
>>> Nathan
>>>
>


-- 
---------------------------------------------------------------------
Rick Matthews                           email: Rick.Matthews at sun.com
Sun Microsystems, Inc.                  phone:+1(651) 554-1518
1270 Eagan Industrial Road              phone(internal): 54418
Suite 160                               fax:  +1(651) 554-1540
Eagan, MN 55121-1231 USA                main: +1(651) 554-1500		
---------------------------------------------------------------------
