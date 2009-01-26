From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Mon, 26 Jan 2009 13:53:27 -0800
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
Message-ID: <497E30D7.3020208@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On Jan 23, 2009  10:46 -0600, Harriet G. Coverston wrote:
>   
>> SAM supports classification policy rules for files  -- (1) number of  
>> copies, up to 4 (2) where to put the copies  on which vsn pools  -  
>> disk and/or tape, local and/or remote) (3) when to make the copies  
>> (time based archiving). You specify the policy in the archiver.cmd  
>> file. You can group files for a policy rule by pathname, owner, group,  
>> size, wildcard, and access time.
>>     
My point about this is that files will be stored using the FID as the 
file name, so name-based policies at the copytool level are worthless.   
Unless we a.) add the path/filename back to the file (EA?), and b.) 
modify the SAM policy engine to use the "real" path/filename instead of 
the FID.
>> This brings up the question of restore. In case of a Lustre disk  
>> failure, how are you going to restore your Lustre file system?
>>     
>
> ...
>   
> - since the archive does not contain a copy of the namespace (it only
>   has 128-bit FIDs as identifiers for the file) we would need to make
>   a separate backup of the MDS filesystem (which is all namespace).
>   There are already several mechanisms to do this, either using the
>   ext2 "dump" program to read from the raw device, or to make an LVM
>   snapshot and use e.g. tar to make a filesystem-level backup.  Both
>   of these need to include a backup of the extended attributes.
>   
Or include the path/filename in each file, and the restore process uses 
this to repopulate the filesystem.
>   
>> Agree. I don't see any SAM-QFS code changes required. The Lustre  
>> copytool will write to HPSS using the HPSS APIs and write to SAM-QFS  
>> with a ftp or pftp interface. This is minimum changes.
>>     
>
> We weren't thinking of using an FTP interface to SAM, though I guess
> this is possible.  Rather we were thinking of just mounting both QFS
> and Lustre on a Linux client and using "cp" or equivalent tool.
>   
Harriet already knew this, she just forgot :)
