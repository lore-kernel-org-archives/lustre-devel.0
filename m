From: John Hammond <jhammond@tacc.utexas.edu>
Date: Mon, 1 Aug 2011 11:10:15 -0500
Subject: [Lustre-devel] open(), getattr(), and negative dentries
In-Reply-To: <6A3C39D7-A059-4E1A-B73E-92F84AA2DE7D@whamcloud.com>
References: <4E2888D2.7090201@tacc.utexas.edu>
	<6A3C39D7-A059-4E1A-B73E-92F84AA2DE7D@whamcloud.com>
Message-ID: <4E36CFE7.3020902@tacc.utexas.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 07/27/2011 12:02 AM, Oleg Drokin wrote:
> Hello!
> 
> On Jul 21, 2011, at 4:15 PM, John Hammond wrote:
> 
>> It appears that stating a non-existent file on Lustre causes a negative
>> dentry to be created, while opening it does not.  If I understand
>> correctly, this also means that every open of a non-existent file that
>> misses the dentry cache causes an RPC to the MDS.  Is there a reason for
>> the difference?
> 
> Open does not return a parent dir lock back to the client and this is what guards
> negative dentries.
> So if you do ls -l on the dir, and then do your open (without O_CREATE!)
> the negative dentry will be cached because of the pre-existing lock.
> In fact is the dir was last modified sufficiently long ago (like several seconds have passed),
> even lookup of the dir itself (even done as part of the path lookup to the filename)
> would return you the needed lock and negative dentry will be cached.

Thanks, that's helpful.  I assume that "sufficiently long ago" means
after ns_ctime_age_limit (10 by default) seconds have passed.  I
adjusted my test case to account for this but there still seems to be an
issue here, so I created LU-560.

Best,

John

-- 
John L. Hammond, Ph.D.
TACC, The University of Texas at Austin
jhammond at tacc.utexas.edu
(512) 471-9304
