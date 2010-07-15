From: John Hammond <jhammond@ices.utexas.edu>
Date: Thu, 15 Jul 2010 13:57:51 -0500
Subject: [Lustre-devel] async write and abort_recov
In-Reply-To: <F8ED1D1B-A853-4C8B-8236-9CC514EF8F52@oracle.com>
References: <4C3AE9FC.5010705@cea.fr>	<4EC6AD38-0BE5-4DDC-B98A-C1C835292305@oracle.com>	<4C3EC133.2030800@cea.fr>
	<F8ED1D1B-A853-4C8B-8236-9CC514EF8F52@oracle.com>
Message-ID: <4C3F5A2F.2010105@ices.utexas.edu>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On 07/15/2010 11:19 AM, Andreas Dilger wrote:
> On 2010-07-15, at 02:05, Aurelien Degremont wrote:
>> Andreas Dilger a ?crit :
>>> While I know Lustre will save errors from async write RPCs into
>>> the file descriptor for later write calls or fsync), I don't know
>>> if we save any IO error into the file descriptor if we discard
>>> pages due to eviction.  I think only errors due to currently
>>> in-flight RPCs that are aborted due to client eviction are
>>> returned.

If the async write fails due to eviction then writepage() will store 
-ESHUTDOWN in the inode info's lli_async_rc member.

>> Sounds like a bug to me?  That means, if a process write data on a
>> client, those data goes to page cache.  Not yet to OST if there is
>> no local memory pressure. At that moment, if the client is evicted,
>> those pages are dropped. Then client reconnect, the process writes
>> other data. Those I/O are successful, client has missed that some
>> previous I/O failed?

I filed a bug because the async errors weren't being reported, see 
https://bugzilla.lustre.org/show_bug.cgi?id=22360.  It looks like this 
is addressed in 1.8.4.  Thereafter they should be reported on the next 
call to close() for that inode; but note that the error need not go to 
the processes whose writes were lost.  Tant pis!

-- 
John L. Hammond, Ph.D.
ICES, The University of Texas at Austin
jhammond at ices.utexas.edu
(512) 471-9304
