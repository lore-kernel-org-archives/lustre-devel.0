From: Nicolas Williams <Nicolas.Williams@sun.com>
Date: Fri, 2 Oct 2009 17:06:12 -0500
Subject: [Lustre-devel] Needed: insight on obd_set_info_async()
Message-ID: <20091002220611.GU887@Sun.COM>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org

I'm trying to find out which uses of obd_set_info_async() involve values
that come from a PTLRPC message buffer, and which ones don't.  It would
help to know what obd_set_info_async() is for...  It seems it's a
glorified ioctl()...

I'm tempted to augment it to always take a struct ptlrpc_request *req
argument, so that req == NULL || val == NULL, and when req != NULL the
value will be obtained using req_capsule_*_get().  Between that and
enhancements to req_capsule_extend() and what not we might be able to
ensure that 'val' is always swabbed by capsule code.

But if the uses of obd_set_info_async() are very clearly distinguishable
it might be better to introduce a variant that takes a struct
ptlrpc_request *req _instead_ of val/vallen.

Comments?

Nico
-- 
