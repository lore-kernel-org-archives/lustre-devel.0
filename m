From: Harriet G. Coverston <Harriet.Coverston@Sun.COM>
Date: Mon, 26 Jan 2009 18:12:49 -0600
Subject: [Lustre-devel] SAM-QFS, ADM, and Lustre HSM
In-Reply-To: <20090126194744.GG3652@webber.adilger.int>
References: <3DF0F4AF-F4D6-476E-98F7-CD912C49FC18@Sun.COM>
	<2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com>
	<4977E5BD.7000706@sun.com> <4978DB1E.30507@sun.com>
	<9365C284-E805-46B6-95B2-226C1E2ED112@Sun.COM>
	<20090126194744.GG3652@webber.adilger.int>
Message-ID: <772D922B-11B2-4494-A95A-4820FD214CC6@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas,

On Jan 26, 2009, at 1:47 PM, Andreas Dilger wrote:

> On Jan 23, 2009  10:46 -0600, Harriet G. Coverston wrote:
>> SAM supports classification policy rules for files  -- (1) number of
>> copies, up to 4 (2) where to put the copies  on which vsn pools  -
>> disk and/or tape, local and/or remote) (3) when to make the copies
>> (time based archiving). You specify the policy in the archiver.cmd
>> file. You can group files for a policy rule by pathname, owner,  
>> group,
>> size, wildcard, and access time.
>>
>> This brings up the question of restore. In case of a Lustre disk
>> failure, how are you going to restore your Lustre file system?
>
> The initial HSM implementation is focussed mainly on the space  
> management
> issues, rather than backup/restore, though of course there is a lot of
> overlap between the two and we have discussed backup aspects in the  
> past.

I do see below that you are dumping your metadata which maps the 128- 
FIDs to
the full pathname. In this case, you would be able to restore your  
Luster
file system from the archive.  If you don't have this restore feature,  
then you would
just be using the archive as a disk extender and you would also need a  
conventional
backup.
>
> There are two main issues that would need to be addressed:
> - a Lustre-level policy on the minimum file size that should be sent  
> to
>  the archive.  For Lustre, there would be minimal space savings if a
>  small file is moved to the archive, so that would only be useful in
>  the archive-as-backup case.
>
>  We would need to decide whether the HPSS implementation can/should
>  handle aggregating multiple small files into a single archive object.
Last I knew, they still don't build a container for small files. They  
write
a tape mark between each file. This means they are start/stopping the
tape for small files. A lot of sites use SRB which builds a tar  
container.
>
>  I think that is useful, and this is one reason I advocate being able
>  to pass multiple files at once from the coordinator to the agent.
If you decided to build a container, then that will work for both HPSS  
and
SAM.
>
>
> - since the archive does not contain a copy of the namespace (it only
>  has 128-bit FIDs as identifiers for the file) we would need to make
>  a separate backup of the MDS filesystem (which is all namespace).
>  There are already several mechanisms to do this, either using the
>  ext2 "dump" program to read from the raw device, or to make an LVM
>  snapshot and use e.g. tar to make a filesystem-level backup.  Both
>  of these need to include a backup of the extended attributes.
>
>> Agree. I don't see any SAM-QFS code changes required. The Lustre
>> copytool will write to HPSS using the HPSS APIs and write to SAM-QFS
>> with a ftp or pftp interface. This is minimum changes.
>
> We weren't thinking of using an FTP interface to SAM, though I guess
> this is possible.  Rather we were thinking of just mounting both QFS
> and Lustre on a Linux client and using "cp" or equivalent tool.
> Depending on the performance requirements, it might make sense to
> use a smarter tool that avoids the kernel-user-kernel memory copies.
Yes, we support Linux clients and you can use the datamover  
architecture.
You benefit with direct access to the storage from both the Lustre
file system and the SAM file system, no OTW performance penalty. I  
would not
recommend cp since it is mmap I/O (on Solaris, not sure about Linux).  
You will
want to use direct I/O to avoid the useless data copy. If you use ftp/ 
pftp/gridftp,
that is just a loop back move on the datamover(s); however, any  
standard file system
interface will work to SAM.
>
>
>> I do see work to switch the HPSS APIs to ftp or pftp. If this is
>> already supported by HPSS, then, yes, no changes are required.
>
> I think CEA is planning on writing a copytool using the HPSS APIs
> directly.  There is also "htar" which is a tar-like interface to
> HPSS, but I don't think that was anyone's intention to use.

If they decide to use the non standard HPSS APIs, then yes, there  
would be changes
required to use a standard file system interface for SAM.

Best regards,

- Harriet
>
>
> Cheers, Andreas
> --
> Andreas Dilger
> Sr. Staff Engineer, Lustre Group
> Sun Microsystems of Canada, Inc.
>

    - Harriet

Harriet G. Coverston
Solaris, Storage Software			 |  Email: harriet.coverston at sun.com
Sun Microsystems, Inc.                     	 |  AT&T:  651-554-1515
1270 Eagan Industrial Rd., Suite 160       |  Fax:   651-554-1540
Eagan, MN 55121-1231
