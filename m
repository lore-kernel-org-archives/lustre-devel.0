From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 30 May 2018 15:06:38 +0300
Subject: [lustre-devel] [PATCH] staging: lustre: libcfs: add parens
 around macros args
In-Reply-To: <20180522133439.12338-1-brnkv.i1@gmail.com>
References: <20180522133439.12338-1-brnkv.i1@gmail.com>
Message-ID: <20180530120638.lap3libc5nxmzb4o@mwanda>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: Ivan Bornyakov <brnkv.i1@gmail.com>
Cc: lustre-devel@lists.lustre.org, devel@driverdev.osuosl.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, oleg.drokin@intel.com, andreas.dilger@intel.com

On Tue, May 22, 2018 at 04:34:39PM +0300, Ivan Bornyakov wrote:
> One may call 'CFS_FAIL_TIMEOUT(id, secs + 5);' and get unexpected result
> after macro substitution, viz., 'secs + 5' will turn into
> 'secs + 5 * 1000'
> 

We actually do that in ptl_send_rpc() as well so this is a real bug.

It's sort of an interesting coincidence that the code in ptl_send_rpc()
looks almost exactly like your theoretical code:

	OBD_FAIL_TIMEOUT(OBD_FAIL_PTLRPC_DELAY_SEND, request->rq_timeout + 5);

regards,
dan carpenter
