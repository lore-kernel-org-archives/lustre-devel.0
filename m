From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Date: Tue, 24 Mar 2015 16:15:25 -0400
Subject: [lustre-devel] Fwd: proposed version change for PTLRPC GSS
In-Reply-To: <CAC2+cFgRWEEALvwhOiSdhiapkvE=VeeiZ_KeNihud0bxN8y2ew@mail.gmail.com>
References: <CAC2+cFgRWEEALvwhOiSdhiapkvE=VeeiZ_KeNihud0bxN8y2ew@mail.gmail.com>
Message-ID: <CAC2+cFip2cDfT1xAKvo+QKEr2oVnx0iQxTC8D1vDMNXyDtY-pQ@mail.gmail.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'm sending to lustre-devel for wider distribution/comment.

---------- Forwarded message ----------
From: Jeremy Filizetti <jeremy.filizetti@gmail.com>
Date: Mon, Mar 23, 2015 at 9:34 PM
Subject: proposed version change for PTLRPC GSS
To: "iudev at lists.opensfs.org" <iudev@lists.opensfs.org>


On the phone call last week we discussed an increment of the
PTLRPC_GSS_VERSION to version 2 to allow some changes
changes/restructuring.  No one had any objections on the phone call but I
wanted to send it out for wider distribution and feedback.

Changing the request format would allow us to support larger GSS token
sizes which today are limited (see ticket LU-3855).   From what I have
looked through so far the following seems to allow for larger tokens and
also allow some of these changes without having to worry about backwards
compatibility since it was never really "working" anyways.

Change PTLRPC_GSS_VERSION to 2

Enlarge GSS_CTX_INIT_MAX_LEN to something larger then 1024.   Ideally we
would support MaxTokenSize of 64k for the largest active directory ticket:
(see
http://blogs.technet.com/b/shanecothran/archive/2010/07/16/maxtokensize-and-kerberos-token-bloat.aspx
).
The purpose of enlarging this is to support larger tokens.  The
sizeof(struct rsi) needs to remain under PAGE_SIZE right now with
rsi_request calling sunrpc_cache_pipe_upcall.  Since there is only one
lsvcgssd process supposed to be running maybe it would be acceptable to use
larger requests and just slightly modify rsi_request to incorporate must of
the functionality of sunrpc_cache_pipe_upcall.

To keep things simple with the lsvcgssd and continue to use a single
channel proc file interface I'd like to AND the GSS subflavor onto most
significant bits of lustre_svc in struct rsi.  Instead of calling the
inappropriately named handle_nullreq things would be changed to handle the
multiple subflavors (gssnull, sk, krb5).  gssnull and sk won't have a full
userspace component so gss_accept_sec_context can't be called.

Thoughts welcome.  I'm sure I missed something along the way here but this
is just what I have looked at so far.

Thanks,
Jeremy
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20150324/6879d571/attachment.htm>
