From: James Simmons <jsimmons@infradead.org>
Date: Mon, 26 Nov 2018 03:54:26 +0000 (GMT)
Subject: [lustre-devel] lustre migration bug
Message-ID: <alpine.LFD.2.21.1811260347400.32255@casper.infradead.org>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


Most of the major bugs outstanding are for migration functionality.
I did some tracing in the code (ll_migrate -> lmv_rename -> mdc_rename)
and found the failures is due to errors returned from after_reply() in
the ptlrpc layer. From that I see that the server is reporting that
the RPC packets are invalid. So far I don't see why exactly this is
the case. I will need to debug on the server side to figure it out.
