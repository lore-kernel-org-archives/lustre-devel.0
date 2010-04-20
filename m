From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Tue, 20 Apr 2010 15:43:00 -0500
Subject: [Lustre-devel] Flush on file close
In-Reply-To: <20100420202740.GY10389@Sun.COM>
References: <201004192230.48196.andrew.perepechko@sun.com>
	<20100420202740.GY10389@Sun.COM>
Message-ID: <20100420204300.GZ10389@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Apr 20, 2010 at 03:27:40PM -0500, Nicolas Williams wrote:
> However, when writes deferred at close(2) time fail on a local
> filesystem...  chances are that subsequent I/O will just fail.  Or at
> least that's probably what many users will expect.  But does POSIX
> require that?  I don't have it handy, but I'm pretty sure the answer is
> "no".  With Lustre we could also have a close(2) whose deferred writes
> fail long after the process that could handle the failure is gone.

To go out on a complete limb :) what we really need is a variant of
close(2) where eventual failure can be caught, even when the process
that called it has exit()ed.  Something like:

int close_or_spawn(int fd, <posix_spawn()-like arguments>);

or

int close_xid(int fd, uint64_t xid);   /*
                                        * Where some daemon(s) reads a
					* log of sucessful/failed close
					* XIDs and takes action as
					* necessary.
					*/

I prefer something along the lines of close_xid().

Adoption of new APIs in the context of Lustre is probably more
realistic than in the general case, but it'd still be slow.

So we're still left with: you'd better fsync(2) explicitly before
close()ing if you want to make sure that you don't lose data.

Nico
-- 
