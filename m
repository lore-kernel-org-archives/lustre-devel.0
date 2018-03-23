From: Doug Oucharek <doucharek@cray.com>
Date: Fri, 23 Mar 2018 05:54:23 +0000
Subject: [lustre-devel] [PATCH] staging: lustre: lnet: use correct
 'magic' test
In-Reply-To: <20180321195302.GA9465@tanglefoot>
References: <20180321195302.GA9465@tanglefoot>
Message-ID: <3A319066-1DE5-4E9C-B862-9206775D3683@cray.com>
List-Id: <lustre-devel-lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: lustre-devel@lists.lustre.org


On Mar 21, 2018, at 12:53 PM, Justin Skists <j.skists at gmail.com<mailto:j.skists@gmail.com>> wrote:

Use the lnet_magic_accept() function to compare 'magic' against
LNET_PROTO_TCP_MAGIC for the appropriate string for an error message.

The original fix removed an unneeded byte-ordering cast because the define
was already CPU byte-ordered and it was assumed that 'magic' was CPU
byte-ordered, too.

Now modify the if-statement to use the appropriate lnet_accept_magic()
function in order to be consistent with similar tests. This will allow
the code to be consistent with the general understanding that 'magic'
should be in host-byte-order for the peer that sent the message.

Fixes: 80782927e3aa ("staging: lustre: Fix unneeded byte-ordering cast")
Cc: NeilBrown <neilb at suse.com<mailto:neilb@suse.com>>
Signed-off-by: Justin Skists <j.skists at gmail.com<mailto:j.skists@gmail.com>>
---
drivers/staging/lustre/lnet/lnet/acceptor.c | 2 +-
1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/lustre/lnet/lnet/acceptor.c b/drivers/staging/lustre/lnet/lnet/acceptor.c
index 13e981781b9a..5648f17eddc0 100644
--- a/drivers/staging/lustre/lnet/lnet/acceptor.c
+++ b/drivers/staging/lustre/lnet/lnet/acceptor.c
@@ -240,7 +240,7 @@ lnet_accept(struct socket *sock, __u32 magic)
return -EPROTO;
}

- if (magic == LNET_PROTO_TCP_MAGIC)
+ if (lnet_accept_magic(magic, LNET_PROTO_TCP_MAGIC))
str = "'old' socknal/tcpnal";
else
str = "unrecognised";
--
2.16.2

Reviewed by: Doug Oucharek <dougso at me.com<mailto:dougso@me.com>>



_______________________________________________
lustre-devel mailing list
lustre-devel at lists.lustre.org<mailto:lustre-devel@lists.lustre.org>
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/attachments/20180323/d2263fa1/attachment.html>
