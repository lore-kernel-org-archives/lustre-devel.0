From: NeilBrown <neilb@suse.com>
Date: Tue, 03 Jul 2018 14:26:08 +1000
Subject: [lustre-devel] [PATCH 08/18] lustre: security: send file
 security context for creates
In-Reply-To: <1530573875-20465-9-git-send-email-jsimmons@infradead.org>
References: <1530573875-20465-1-git-send-email-jsimmons@infradead.org>
 <1530573875-20465-9-git-send-email-jsimmons@infradead.org>
Message-ID: <87r2kl0wtb.fsf@notabene.neil.brown.name>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

On Mon, Jul 02 2018, James Simmons wrote:

> From: "John L. Hammond" <jhammond@whamcloud.com>
>
> Send file security context to MDT along with create RPCs. This closes
> the insecure window between creation and setting of the security
> context that existed previously. It also avoids a potential LDLM hang
> which arises from ll_create_it() when we send a MDS_SETXATTR RPC while
> holding the lookup+layout lock returned from open.
>


>  
> -err_exit:
> +out_inode:
> +	if (inode)
> +		iput(inode);

iput() allows NULL to be passes (as all 'release' function should)
so this can be just
	iput(inode);


Thanks,
NeilBrown
-------------- next part --------------
A non-text attachment was scrubbed...
Name: signature.asc
Type: application/pgp-signature
Size: 832 bytes
Desc: not available
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180703/8744f815/attachment.sig>
