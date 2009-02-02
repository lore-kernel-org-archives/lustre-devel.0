From: Harriet G. Coverston <Harriet.Coverston@Sun.COM>
Date: Mon, 02 Feb 2009 09:07:54 -0600
Subject: [Lustre-devel] SAM-QFS, ADM, and Lustre HSM
In-Reply-To: <4987098F.402@Sun.COM>
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
Message-ID: <367E32B4-A759-45AD-9D2C-48C051FE1D62@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Colin,

On Feb 2, 2009, at 8:56 AM, Colin Ngam wrote:

>>>
>>>
>>> Harriet G. Coverston wrote:
>>>>> There is a mechanism to get the current full pathname for a  
>>>>> given fid from userspace, so an HSM-specific copytool could find  
>>>>> it out, but a central tenet of the design here is that as far as  
>>>>> the HSM is concerned, the entire Lustre FS is a flat namespace  
>>>>> of FIDs.
>>>>
>>>> Be careful here. We are a file system. We don't have a limit on #  
>>>> of files in one directory, but we don't recommend more than  
>>>> 500,000 files in one single directory or you will start to see  
>>>> some performance problems. You will have to create a tree, not  
>>>> use a flat namespace.
>>> Yes, a tree based on a hash of the fid.
>>> The other option is to use the actual filename for storage, but  
>>> from Lustre's point of view this gets extremely tricky.  For  
>>> example:
>>> Send /foo/bar to archive.  Client A opens /foo/bar.  Client B  
>>> renames /foo/bar to /abc/xyz, but this change hasn't propagated to  
>>> the archive yet.  Client A now tries to read its open file handle,  
>>> which tells Lustre to read the offline file FID 123, which it  
>>> translates to /abc/xyz currently, which the archive doesn't know  
>>> about yet.  Not just xyz, but renames on any ancestor path element  
>>> cause similar misses.  Since the FID remains constant throughout  
>>> the life of a file, we don't have to worry about any namespace  
>>> changes (file or parents).  If there was an alternate way of  
>>> bypassing the archive's namespace to directly access a file, we  
>>> could conceivably store e.g. an archive-specific identifier within  
>>> the Lustre stripe EA, and pass this down to the copytool when  
>>> reading an offline file, but this presupposes that such a thing  
>>> exists, is of reasonable size, has a userspace method to access  
>>> it, etc.
>>
>> Yes, we have a FID like concept in SAM-QFS. It is called the file  
>> ID. It is 64 bits and consists of the inode/generation number. It  
>> is unique. You can store it. You can issue an ioctl to open the ID.  
>> You
>> can issue an ioctl to do an ID stat, etc. It is much more efficient  
>> than using the filename (expensive lookup). This means if you store  
>> and use the ID, you can cover the rename window and still be  
>> guaranteed that you will get the right file. Note, we don't  
>> rearchive on a rename.
> I believe this facility only exist on the Meta Data Server Node and  
> not on the Linux/Solaris clients.  Am I correct?
It is supported on the MDS and the Solaris client nodes, but currently  
not on Linux.

I thought about this a bit. After we do a samfsrestore (reload the  
metadata after a crash of the SAM-QFS disk cache), the ID is not the  
same. Therefore, you would not be able to use this after a SAM restore  
unless
the ID that you are storing is updated. We really need to think about  
this.

- Harriet
>
>
> Thanks.
>
> colin
>>
>> I really think a replicated namespace will be much more intuitive  
>> and solves restore. If you prefer
>> to build a tar container, that is OK, too. The tar file can have a  
>> suffix and then you know it is tar and
>> you can tar it back.
>>>
>>>
>>>>
>>>>> You can get a full pathname if you want to for catastrophe  
>>>>> recovery, but Lustre itself will only speak to the HSM with FIDs.
>>>>> As I said in the other email, although SAM-QFS can do name-based  
>>>>> policies, the "name" as far as QFS is concerned is just the FID,  
>>>>> so  name-based policies at the copytool level are worthless.    
>>>>> Unless we a.) add the path/filename back to the file (EA, or use  
>>>>> a tarball wrapper), and b.) modify the SAM policy engine to use  
>>>>> the "real" path/filename instead of the FID.
>>>>
>>>> Currently, we don't support policy using EA (extended attributes  
>>>> are in 5.0). We have had lots of requests for this, especially  
>>>> from our digital preservation customers.
>>> Ah, policy based on EAs would be the general case, yes.
>> Yes, this would be a nice feature for us.
>>
>>   - Harriet
>>
>> Harriet G. Coverston
>> Solaris, Storage Software             |  Email: harriet.coverston at sun.com
>> Sun Microsystems, Inc.                          |  AT&T:   
>> 651-554-1515
>> 1270 Eagan Industrial Rd., Suite 160       |  Fax:   651-554-1540
>> Eagan, MN 55121-1231
>>
>>
>>
>>
>

    - Harriet

Harriet G. Coverston
Solaris, Storage Software			 |  Email: harriet.coverston at sun.com
Sun Microsystems, Inc.                     	 |  AT&T:  651-554-1515
1270 Eagan Industrial Rd., Suite 160       |  Fax:   651-554-1540
Eagan, MN 55121-1231
