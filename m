From: Alex Zhuravlev <Alex.Zhuravlev@Sun.COM>
Date: Mon, 30 Jun 2008 12:10:17 +0400
Subject: [Lustre-devel] some thoughts on COS
In-Reply-To: <C46FF0A8.591A%peter.braam@sun.com>
References: <C46FF0A8.591A%peter.braam@sun.com>
Message-ID: <486894E9.1030104@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Hi,

all access to an object can be broken into 3 phases:
1) lock is acquired and used to modify data, no concurrent
    access as data is inconsistent
2) data is consistent, but uncommitted; thus same client can
    access data, others can not
3) all clients can access data

it'd make sense to have same lock handle for (1) and (2) as it
is stored in request and later used to release lock up on commit.

(1) and (3) are clear - this is just lock acquired and lock released.

what if we introduce new lock state (bit, whatever) compatible with
one client (some tag in the lock) and incompatible with others?
in order to keep same lock handle we convert lock (1) into lock (2).
conversion isn't a new conception, we did it before.

then, regular create would look like:

1) lockh = enqueue(PW, clientid); // clientid is stored in the lock
2) object creation; directory modification
3) ptlrpc_save_lock(req, lockh)
      convert(lockh, PW, OWN)
...
4) commit
      lock_decref(lockh, OWN)

also, we'd have to register blocking AST in MDS in order to intercept
collision when one client tries to access data modified by another one.
from that handling we could initiate or schedule sync commit.

this looks like a quite simple conception. but it's far from being
optimal - what if one client does thousand creations, we'll end with
thousand OWN locks, while to prevent alien access we need a single one.
couple ideas can be used here:
1) cache locks on the MDS side as per Nikita's suggestion
2) drop all OWN locks from completion AST

please comments, thoughts?

thanks, Alex
