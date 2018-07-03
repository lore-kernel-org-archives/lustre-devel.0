From: NeilBrown <neilb@suse.com>
Date: Tue, 03 Jul 2018 13:04:48 +1000
Subject: [lustre-devel] [PATCH 01/18] lustre: grant: add support for
 OBD_CONNECT_GRANT_PARAM
In-Reply-To: <1530573875-20465-2-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-2-git-send-email-jsimmons@infradead.org>
Message-ID: <87601x2f5b.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 02 2018, James Simmons wrote:

> From: Johann Lombardi <jlombardi@whamcloud.com>
>
> Add support for grant overhead calculation on the client side.
> To do so, clients track usage on a per-extent basis. An extent is
> composed of contiguous blocks.
> The OST now returns to the OSC layer several parameters to consume
> grant more accurately:

Just to be sure that I'm understanding correctly, should "consume"
above be "compute" ??

>
> - the backend filesystem block size which is the minimal grant
>   allocation unit;
> - the maximum extent size;
> - the extent insertion cost.
>   Clients now pack in bulk write how much grant space was consumed for
>   the RPC. Dirty data accounting also adopts the same scheme.
>
> Moreover, each backend OSD now reports its own set of parameters:
> - For ldiskfs, we usually have a 4KB block size with a maximum extent
>   size of 32MB (theoretical limit of 128MB) and an extent insertion
>   cost of 6 x 4KB = 24KB
> - For ZFS, we report a block size of 128KB, an extent size of 128
>   blocks (i.e. 16MB with 128KB block size) and a block insertion cost
>   of 112KB.
>
> Besides, there is now no more generic metadata overhead reservation
> done inside each OSD. Instead grant space is inflated for clients
> that do not support the new grant parameters. That said, a tiny
> percentage (typically 0.76%) of the free space is still reserved
> inside each OSD to avoid fragmentation which might hurt performance
> and impact our grant calculation (e.g. extents are broken due to
> fragmentation).
>
> This patch also fixes several other issues:
>
> - Bulk write resent by ptlrpc after reconnection could trigger
>   spurious error messages related to broken dirty accounting.
>   The issue was that oa_dirty is discarded for resent requests
>   (grant flag cleared in ost_brw_write()), so we can legitimately
>   have grant > fed_dirty in ofd_grant_check().
>   This was fixed by resetting fed_dirty on reconnection and skipping
>   the dirty accounting check in ofd_grant_check() in the case of
>   ptlrpc resend.

ofd_grant_check doesn't appear in this patch.  Presumably it was part of
the server code that was stripped from the patch.

>
> - In obd_connect_data_seqprint(), the connection flags cannot fit
>   in a 32-bit integer.

I cannot see what this might refer to either.

>
> - When merging two OSC extents, an extent tax should be released
>   in both the merged extent and in the grant accounting.

I think I might see what this relates to.

> +static ssize_t cur_dirty_grant_bytes_show(struct kobject *kobj,
> +					  struct attribute *attr,
> +					  char *buf)
> +{
> +	struct obd_device *dev = container_of(kobj, struct obd_device,
> +					      obd_kobj);
> +	struct client_obd *cli = &dev->u.cli;
> +	int len;
> +
> +	spin_lock(&cli->cl_loi_list_lock);
> +	len = sprintf(buf, "%lu\n", cli->cl_dirty_grant);
> +	spin_unlock(&cli->cl_loi_list_lock);

Why take the spinlock?? cl_dirty_grant is 'long', so reading it is
atomic.


> +		if (OCD_HAS_FLAG(&cli->cl_import->imp_connect_data,
> +				 GRANT_PARAM)) {
> +			int nrextents;
> +
> +			/*
> +			 * take extent tax into account when asking for more
> +			 * grant space
> +			 */
> +			nrextents = (nrpages + cli->cl_max_extent_pages - 1)  /
> +				     cli->cl_max_extent_pages;

I generally prefer DIV_ROUND_UP() for this.


I don't think any of the above will stop me from applying the patch,
though I might edit the description, and may add a fix-up patch afterwards.

Thanks.
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180703/348eec1f/attachment.sig>
