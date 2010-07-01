From: Nic Henke <nic@cray.com>
Date: Thu, 1 Jul 2010 11:18:43 -0500
Subject: [Lustre-devel] o2iblnd bug ?
Message-ID: <4C2CBFE3.4040901@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

There looks to be a bug in the o2iblnd (and maybe other LNDs...) in 
kiblnd_tx_done.

When tx_lntmsg[1] has a reply allocated (lnet_create_reply_msg) for a 
GET_REQ, we are committed to lnet_finalize that no matter the status of 
the RDMA. However, kiblnd_tx_done will call lnet_finalize() with the 
'error' status on both the request (lntmsg[0]) and the allocated reply. 
This could lead to the upper layer receiving a REPLY event for a message 
it has already nuked due to the EIO on the originial request.

In the pttlnd and qswlnd, they seem to handle this properly. They will 
complete the request with rc=0, then complete the reply with rc=-EIO.

So - is this really a bug or just inconsequential differences ?

This looks to be present in HEAD, as well as b1_8 and friends.

Cheers,
Nic
