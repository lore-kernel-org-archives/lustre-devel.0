From: Nicolas Williams <Nicolas.Williams@oracle.com>
Date: Tue, 20 Apr 2010 15:27:40 -0500
Subject: [Lustre-devel] Flush on file close
In-Reply-To: <201004192230.48196.andrew.perepechko@sun.com>
References: <201004192230.48196.andrew.perepechko@sun.com>
Message-ID: <20100420202740.GY10389@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

POSIX behavior is that close(2) can fail, so if you care, you should
check its error status.  POSIX behavior is also that close(2) doesn't
imply an fsync(2) (much less a sync(2)).

NFS clients implement fsync(2)-on-close, but that's another story.

However, when writes deferred at close(2) time fail on a local
filesystem...  chances are that subsequent I/O will just fail.  Or at
least that's probably what many users will expect.  But does POSIX
require that?  I don't have it handy, but I'm pretty sure the answer is
"no".  With Lustre we could also have a close(2) whose deferred writes
fail long after the process that could handle the failure is gone.

Databases and so on should always fsync(2) when they need to ensure
consistent on-disk state.  Many apps that write(2) don't need to
fsync(2) (think of writes to log files).

Nico
-- 
