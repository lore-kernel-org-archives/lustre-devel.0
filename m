From: Nathaniel Rutman <Nathan.Rutman@Sun.COM>
Date: Mon, 26 Jan 2009 14:13:55 -0800
Subject: [Lustre-devel] SAM-QFS, ADM, and Lustre HSM
In-Reply-To: <20090126193548.GF3652@webber.adilger.int>
References: <3DF0F4AF-F4D6-476E-98F7-CD912C49FC18@Sun.COM>
	<2734A30F-2C76-4725-9F3A-29AD4245B7E8@Sun.COM>
	<496FCA67.6000500@sun.com>
	<48D329C0-242E-4A5A-94C1-DF493BB25C2F@Sun.COM>
	<496FE8D4.2090908@sun.com>
	<BEB67402-7AFE-4BE1-A59C-050823AFC8E5@Sun.COM>
	<4977647D.5010503@sun.com>
	<4977E5BD.7000706@sun.com> <4978DB1E.30507@sun.com>
	<497A144C.4000408@Sun.COM>
	<20090126193548.GF3652@webber.adilger.int>
Message-ID: <497E35A3.3080603@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Andreas Dilger wrote:
> On Jan 23, 2009  13:02 -0600, Rick Matthews wrote:
>   
>>  Having a mover to put data into QFS is a great idea, and can easily use 
>> the QFS Linux client. I don't think you would necessarily get QFS
>> policy for native Lustre files unless the "moved" files retained the
>> Lustre attributes, from which you want policy decisions made.
>>     
>
> There will not necessarily be HSM policy data stored with every file
> from Lustre, though there is a desire to store Lustre layout data in
> the archive.  Is it possible to store extended attributes with each
> file in QFS?
>   
We can always store EA's, either natively or "poor-man's EA's" via 
mini-tarballs.
>   
>> The applicable Lustre namespace would be essentially duplicated in the
>> QFS space, and (I think) QFS classification and policy occur on that  
>> name space. Doing so gives you access to rich QFS policy. This also
>> allows QFS to migrate data to/from archive media without I/O or
>> compute load on any Linux clients.
>>     
>
> The current Lustre HSM design will not export any of the filesystem
> namespace to the archive, so that we don't have to track renames in
> the archive.  The archive objects will only be identified by a Lustre
> FID (128-bit file identifier).  IIRC, the HSM-specific copy tool would
> be given the file name (though not necessarily the full pathname) in
> order to perform the copyout, but the filesystem will be retrieving the
> file from the archive by FID.  Nathan, can you confirm that is right?
>   
There is a mechanism to get the current full pathname for a given fid 
from userspace, so an HSM-specific copytool could find it out, but a 
central tenet of the design here is that as far as the HSM is concerned, 
the entire Lustre FS is a flat namespace of FIDs.  You can get a full 
pathname if you want to for catastrophe recovery, but Lustre itself will 
only speak to the HSM with FIDs.
As I said in the other email, although SAM-QFS can do name-based 
policies, the "name" as far as QFS is concerned is just the FID, so  
name-based policies at the copytool level are worthless.   Unless we a.) 
add the path/filename back to the file (EA, or use a tarball wrapper), 
and b.) modify the SAM policy engine to use the "real" path/filename 
instead of the FID.

But in the bigger picture sense, note that all this is simply an 
optimization to allow SAM-QFS filename-based policies, which ultimately 
only influences where SAM-QFS stores files, not whether or when the 
files are archived by Lustre.  These "top-level" policy decisions are 
made by the Lustre policy manager, and so perhaps there is no real need 
to spend any effort getting b.) above working.  Note that a.) is still 
useful for disaster recovery.
