From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 19 Mar 2018 11:14:33 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: o2iblnd: Stop MLX5
 triggering a dump_cqe
In-Reply-To: <B7D07263-126A-4156-AD60-3A58E8852865@me.com>
References: <B7D07263-126A-4156-AD60-3A58E8852865@me.com>
Message-ID: <20180319081433.aqh6xt2t6b2bf22k@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Doug Oucharek <dougso@me.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, "Drokin, Oleg" <oleg.drokin@intel.com>, "Dilger, Andreas" <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

I don't really understand this patch...

On Fri, Mar 16, 2018 at 04:40:21PM -0700, Doug Oucharek wrote:
> We have found that MLX5 will trigger a dump_cqe if we don't
> invalidate the rkey on a newly alloated MR for FastReg usage.
> 
> This fix just tags the MR as invalid on its creation if we are
> using FastReg and that will force it to do an invalidate of the
> rkey on first usage.

This paragraph makes the change seem like a limited workaround for a
bug in the MLX5 code.  Why can't the MLX5 code be fixed instead?

Looking at the patch it doesn't seem like a limitted solution at all.
Now frd->frd_valid is *always* set to false.  Why don't we instead just
delete ->frd_valid along with the newly dead code?

regards,
dan carpenter
