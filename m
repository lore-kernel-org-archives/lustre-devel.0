From: NeilBrown <neilb@suse.com>
Date: Thu, 18 Oct 2018 13:12:39 +1100
Subject: [lustre-devel] [PATCH 20/28] lustre: obdclass: deprecate
 OBD_GET_VERSION ioctl
In-Reply-To: <1539543498-29105-21-git-send-email-jsimmons@infradead.org>
References: <1539543498-29105-1-git-send-email-jsimmons@infradead.org>
 <1539543498-29105-21-git-send-email-jsimmons@infradead.org>
Message-ID: <87a7ncc8a0.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Sun, Oct 14 2018, James Simmons wrote:
>  
> +		if (!warned) {
> +			warned = true;
> +			CWARN("%s: ioctl(OBD_GET_VERSION) is deprecated, use llapi_get_version_string() and/or relink\n",
> +			      current->comm);
> +		}

Is there a good reason not to use WARN_ON_ONCE() here?

Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20181018/21914395/attachment.sig>
