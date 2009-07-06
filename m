From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Mon, 6 Jul 2009 17:37:37 -0500
Subject: [Lustre-devel] Recovering opens by reconstruction
In-Reply-To: <20090706172009.GK15302@Sun.COM>
References: <20090702223944.GR15302@Sun.COM> <20090706172009.GK15302@Sun.COM>
Message-ID: <20090706223737.GY15302@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 06, 2009 at 12:20:09PM -0500, Nicolas Williams wrote:
> Note too that recovering opens by reconstruction and before outstanding
> transactions commits us to always use capabilities.  The reason is that
> an open might not be permitted prior to replaying, say, a chmod, but
> with capabilities the open would be permitted because of the capability
> issued earlier, before the MDS restarted.
> 
> If we want an option to disable capabilities, then we should recover
> opens in order at RPC replay time, but the opens should still not be
> replays (unless O_CREAT is involved and that transaction hasn't
> committed).

The above is all wrong, fortunately :)  Oleg explained it to me.

Transactions are committed linearly in time, so if a chmod that an open
depends on has not yet committed then that open's state must be
recovered by replay rather than by reconstruction.

Nico
-- 
