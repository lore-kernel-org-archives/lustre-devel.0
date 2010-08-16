From: Ken Hornstein <kenh@cmf.nrl.navy.mil>
Date: Mon, 16 Aug 2010 11:13:32 -0400
Subject: [Lustre-devel] Caching the root directory
In-Reply-To: <1A6F49A5-1714-4B7F-A960-B6D1092EEBDE@oracle.com>
Message-ID: <201008161513.o7GFDWbe023712@hedwig.cmf.nrl.navy.mil>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

>Well, there is a simple rule for a root of the fs. The rule says
>the parent of the root inode is the root inode.

Hm, I had just tried that, but it didn't seem to work; I'll have to see
what's going on there.

>Besides, when you do getattr by fid (which you do from ll_inode_revalidate),
>you don't have parent anyway, so you onl supply child inode information.

Well, if you just call md_getattr(), yes, you can do that with just the
FID in question; that works fine, and I do that now.  But if you want
to get a lock so you can cache the attributes using md_intent_lock(),
then you DEFINITELY need the parent fid; I learned the hard way that if
you don't include it then the server will throw an LBUG().  This is
presuming you ignore the server's indication of the lack of support for
CONNECT_ATTRFID (see previous thread, but the short deal is that it
was disabled somewhere between 1.8 and 2.0).

--Ken
