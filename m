From: Liang Zhen <Zhen.Liang@Sun.COM>
Date: Fri, 02 Jul 2010 05:27:33 +0800
Subject: [Lustre-devel] o2iblnd bug ?
In-Reply-To: <4C2CBFE3.4040901@cray.com>
References: <4C2CBFE3.4040901@cray.com>
Message-ID: <4C2D0845.9030405@sun.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

Nic Henke wrote:
> There looks to be a bug in the o2iblnd (and maybe other LNDs...) in 
> kiblnd_tx_done.
>
> When tx_lntmsg[1] has a reply allocated (lnet_create_reply_msg) for a 
> GET_REQ, we are committed to lnet_finalize that no matter the status of 
> the RDMA. However, kiblnd_tx_done will call lnet_finalize() with the 
> 'error' status on both the request (lntmsg[0]) and the allocated reply. 
> This could lead to the upper layer receiving a REPLY event for a message 
> it has already nuked due to the EIO on the originial request.
>
>   

Nic,

I think lnet_create_reply_msg has already taken an extra reference on MD 
(lnet_create_reply_msg()->lnet_commit_md()), so the upper layer message 
shouldn't be nuked before the last event(unlinked).

Liang

> In the pttlnd and qswlnd, they seem to handle this properly. They will 
> complete the request with rc=0, then complete the reply with rc=-EIO.
>
> So - is this really a bug or just inconsequential differences ?
>
> This looks to be present in HEAD, as well as b1_8 and friends.
>
> Cheers,
> Nic
> _______________________________________________
> Lustre-devel mailing list
> Lustre-devel at lists.lustre.org
> http://lists.lustre.org/mailman/listinfo/lustre-devel
>   
