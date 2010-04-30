From: Jeremy Filizetti <jfilizetti@sms-fed.com>
Date: Thu, 29 Apr 2010 22:59:42 -0400
Subject: [Lustre-devel] question about ldlm_server_glimpse_ast
Message-ID: <w2je5fcbd181004291959wb9790719ic4dc3a2bd9b64eb@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

In our Lustre WAN environment a few times we've had a link drop for an
extended period of time which causes problems on systems accessing data in
the same directory as the remote system that becomes unavailable.  Our OSS's
seem to be stuck in a loop of ptlrpc_queue_wait called from
ldlm_server_glimpse_ast.  The remote site is accesed through an LNet router
which is still available.  However the OSS resends requests every 7 seconds
successfully to the router but squbsequently with timeout which causes it to
loop in ptlrpc_queue_wait.

Looking over the ldlm_server_blocking_ast and ldlm_server_completion_ast
functions I see they set rq_no_resend = 1, but ldlm_server_glimpse_ast does
not.  I'm not familiar with the locking in Lustre, is there a reason that
ldlm_server_glimpse_ast doesn't set rq_no_resend = 1?  This would get rid of
the loop ptlrpc_queue_wait is stuck in until the client comes back, but I'm
not sure if it would have other unexpected consequences.

Jeremy
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20100429/1d2bc58d/attachment.htm>
