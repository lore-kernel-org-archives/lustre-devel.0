From: Andreas Dilger <adilger@sun.com>
Date: Fri, 30 Jan 2009 16:32:54 -0700
Subject: [Lustre-devel] SOM Recovery of open files
Message-ID: <20090130233253.GK3652@webber.adilger.int>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Vitaly Fertman wrote:
> Oleg told me yesterday about one feature which seems destroying the
> SOM completely.  If a client is evicted and re-connects, we do not
> re-open files so that client thinks files are opened, whereas MDS
> thinks they are closed.

Right.  This issue has been around for a long time.  There is bug 971
dealing with this issue, about changing open file recovery to work by
generating new "open file" requests instead of saving the RPCs and
handling it at the ptlrpc level.  This is (AFAIK) being done for the
simplified interoperability fixes already.

> Thus MDS has no control over opened files, whereas clients may write
> to them.  To fix this we need at least to disable the file modification
> on clients until files are re-opened.

This is also going to be handled by the LOV EA lock that CEA is working
on for HSM and migration.  If the client is evicted from the MDS it will
have the LOV EA lock cancelled, and all IO will block until a new LOV EA
lock is gotten.

> The re-opening itself could be done by application or by us.  In the
> later case, the recovery mechanism is involved...

This is definitely not an application-level problem, it needs to be
fixed within Lustre.

> it was missed for the recovery, but it is a problem for interoperability
> as well. I remember Eric said that we will evict clients on downgrade
> and he said therefore all the files get closed. however, it seems it
> is not for clients unless we do some extra actions.

Even on upgrade, simplified interoperability will now have the server
requesting that all clients flush their state before the server is shut
down, so that the amount of interoperability needed is minimal.  The only
state that a client cannot completely remove is the open file handles,
so the "replay" of file open will now be driven by the file handles
themselves instead of the "saved RPC" mechanism we use today.  That would
also avoid bugs like 3632, 3633, etc.


Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.
