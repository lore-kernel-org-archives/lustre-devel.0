From: Oleg Drokin <Oleg.Drokin@Sun.COM>
Date: Fri, 30 Jan 2009 19:51:54 -0500
Subject: [Lustre-devel] SOM Recovery of open files
In-Reply-To: <20090130233253.GK3652@webber.adilger.int>
References: <20090130233253.GK3652@webber.adilger.int>
Message-ID: <63CF2DAF-59F7-4124-8AE9-188927051AAB@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hello!

On Jan 30, 2009, at 6:32 PM, Andreas Dilger wrote:

> Vitaly Fertman wrote:
>> Oleg told me yesterday about one feature which seems destroying the
>> SOM completely.  If a client is evicted and re-connects, we do not
>> re-open files so that client thinks files are opened, whereas MDS
>> thinks they are closed.
> Right.  This issue has been around for a long time.  There is bug 971
> dealing with this issue, about changing open file recovery to work by
> generating new "open file" requests instead of saving the RPCs and
> handling it at the ptlrpc level.  This is (AFAIK) being done for the
> simplified interoperability fixes already.

But the problem is client might be evicted before such command is issued
and a knowledge about this system would disappear from MDS (but not from
OST where it is still connected).

>> Thus MDS has no control over opened files, whereas clients may write
>> to them.  To fix this we need at least to disable the file  
>> modification
>> on clients until files are re-opened.
> This is also going to be handled by the LOV EA lock that CEA is  
> working
> on for HSM and migration.  If the client is evicted from the MDS it  
> will
> have the LOV EA lock cancelled, and all IO will block until a new  
> LOV EA
> lock is gotten.

LOV EA lock won't help. It does not prevent (with current design,  
anyway)
dirty data flush from client cache, only new writes would be not  
possible.
Even then since there is no reopen when obtaining EA lock, MDS would  
still
have no idea there is an open file handle somewhere.

>> The re-opening itself could be done by application or by us.  In the
>> later case, the recovery mechanism is involved...
> This is definitely not an application-level problem, it needs to be
> fixed within Lustre.

Right. But there is no straightforward fix. It is not going to be easy
to reopen a file after eviction. Of course we can just invalidate
local fd, so that the app will start to get something like ESTALE,
but this approach is also not very desirable.

>> it was missed for the recovery, but it is a problem for  
>> interoperability
>> as well. I remember Eric said that we will evict clients on downgrade
>> and he said therefore all the files get closed. however, it seems it
>> is not for clients unless we do some extra actions.
> Even on upgrade, simplified interoperability will now have the server
> requesting that all clients flush their state before the server is  
> shut
> down, so that the amount of interoperability needed is minimal.  The  
> only

Except in this case the client is evicted from e.g. MDS, so it does not
participate in recovery anyway.

Bye,
     Oleg
