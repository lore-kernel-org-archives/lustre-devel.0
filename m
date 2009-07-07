From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Tue, 7 Jul 2009 11:03:17 -0500
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <4A531BE4.20207@sun.com>
References: <20090702223944.GR15302@Sun.COM> <op.uwh9t2mnatmt0c@garden>
	<20090703215528.GY15302@Sun.COM> <op.uwi7j3uaatmt0c@garden>
	<20090706173441.GL15302@Sun.COM>
	<20090706224203.GZ15302@Sun.COM> <4A531BE4.20207@sun.com>
Message-ID: <20090707160316.GD15302@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Tue, Jul 07, 2009 at 01:56:52PM +0400, Alex Zhuravlev wrote:
> I think it'd be slightly easier to introduce two notions of replay:

As I understand it 'replay' has a very specific meaning: re-send an RPC
with the 'replay' bit set in the ptlrpc header.

> [...]
> my old thougth was that instead of introducing special new open-by-fid
> RPC we should try to implement open in terms of LDLM locks because
> it's in-core state (though with specific tracking of unlinked files).
> given this we'd automatically get single mechanism for all in-core
> states and we'd get rid of special paths for open replays.

Hmmm, but open by FID gives the MDS a chance to check capabilities.
Yes, that's probably not terribly important as long as the OSSes also
check capabilities.

Also, there's the unlink issue to worry about.  Mikhail's proposal for
that is to defer unlinks until after open state recovery (in this case:
until after DLM recovery).  That would work, I think.  Also, you could
have the kind of DLM locks used for open state tracking recovered first,
then transactions, then all other types of locks.

Here's a question: what consumes more memory on the MDS: open state or a
DLM lock?

Nico
-- 
