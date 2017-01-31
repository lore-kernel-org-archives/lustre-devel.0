From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 31 Jan 2017 11:55:42 +0300
Subject: [lustre-devel] [PATCH 22/60] staging: lustre: fid: fix race in
	fid allocation
In-Reply-To: <1485648328-2141-23-git-send-email-jsimmons@infradead.org>
References: <1485648328-2141-1-git-send-email-jsimmons@infradead.org>
	<1485648328-2141-23-git-send-email-jsimmons@infradead.org>
Message-ID: <20170131085542.GI6881@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: James Simmons <jsimmons@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, devel@driverdev.osuosl.org, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Fan Yong <fan.yong@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lustre Development List <lustre-devel@lists.lustre.org>

On Sat, Jan 28, 2017 at 07:04:50PM -0500, James Simmons wrote:
> -		if (!fid_is_zero(&seq->lcs_fid) &&
> -		    fid_oid(&seq->lcs_fid) < seq->lcs_width) {
> +		if (unlikely(!fid_is_zero(&seq->lcs_fid) &&
> +			     fid_oid(&seq->lcs_fid) < seq->lcs_width)) {

What does adding an unlikely have to do with the race condition?  Also
only add likely/unlikely when it makes a difference to benchmarks.
Otherwise leave it out.

>  			/* Just bump last allocated fid and return to caller. */
> -			seq->lcs_fid.f_oid += 1;
> +			seq->lcs_fid.f_oid++;

Ok...  I'm pretty sure the compiler can figure this out on its own.
Stop mixing white space changes into your bug fixes.  It just makes
reviewing more complicated.

>  			rc = 0;
>  			break;
>  		}
>  

regards,
dan carpenter
