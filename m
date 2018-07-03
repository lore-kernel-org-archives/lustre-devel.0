From: NeilBrown <neilb@suse.com>
Date: Tue, 03 Jul 2018 14:20:06 +1000
Subject: [lustre-devel] [PATCH 06/18] lustre: obd: reserve connection
 flag OBD_CONNECT2_FILE_SECCTX
In-Reply-To: <1530573875-20465-7-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-7-git-send-email-jsimmons@infradead.org>
Message-ID: <87tvph0x3d.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 02 2018, James Simmons wrote:

> From: "John L. Hammond" <jhammond@whamcloud.com>
>
> The connection flag OBD_CONNECT2_FILE_SECCTX will be set (in
> ocd_connect_flags2) if an MDT supports setting the file security
> context at create time.
>

>  
> -static void obd_connect_seq_flags2str(struct seq_file *m, __u64 flags, char *sep)
> +static void obd_connect_seq_flags2str(struct seq_file *m, u64 flags,
> +				      u64 flags2, const char *sep)
>  {
> -	__u64 mask = 1;
> +	__u64 mask;
>  	int i;
>  	bool first = true;
>  
> -	for (i = 0; obd_connect_names[i]; i++, mask <<= 1) {
> +	for (i = 0, mask = 1; i < 64; i++, mask <<= 1) {

This changes where the loop stops.  Previously it stopped when
obd_connect_names[i] was NULL.  Now it goes on to 64.
obd_connect_names[] actually has 66 entries, so this isn't
an actual change.  However.... (continued below).

>  		if (flags & mask) {
>  			seq_printf(m, "%s%s",
>  				   first ? sep : "", obd_connect_names[i]);
>  			first = false;
>  		}
>  	}
> -	if (flags & ~(mask - 1))
> +
> +	if (flags & ~(mask - 1)) {
>  		seq_printf(m, "%sunknown flags %#llx",
>  			   first ? sep : "", flags & ~(mask - 1));
> +		first = false;
> +	}

Now that we know i goes up to 64, this code is pointless.
At this point, mask is 0, mask-1 is -1, ~(mask - 1) is zero.
So it cannot print anything.

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180703/91b09b52/attachment.sig>
