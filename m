Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 373B8C433F5
	for <lustre-devel@archiver.kernel.org>; Wed, 29 Dec 2021 14:51:51 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id BBD693AD569;
	Wed, 29 Dec 2021 06:51:45 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 71F963AD37B
 for <lustre-devel@lists.lustre.org>; Wed, 29 Dec 2021 06:51:32 -0800 (PST)
Received: from star.ccs.ornl.gov (star.ccs.ornl.gov [160.91.202.134])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 9566E1006F12;
 Wed, 29 Dec 2021 09:51:28 -0500 (EST)
Received: by star.ccs.ornl.gov (Postfix, from userid 2004)
 id 930A2D9E6F; Wed, 29 Dec 2021 09:51:28 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Wed, 29 Dec 2021 09:51:22 -0500
Message-Id: <1640789487-22279-9-git-send-email-jsimmons@infradead.org>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
References: <1640789487-22279-1-git-send-email-jsimmons@infradead.org>
Subject: [lustre-devel] [PATCH 08/13] lustre: sec: fix handling of encrypted
 file with long name
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
Precedence: list
List-Id: "For discussing Lustre software development."
 <lustre-devel-lustre.org>
List-Unsubscribe: <http://lists.lustre.org/options.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=unsubscribe>
List-Archive: <http://lists.lustre.org/pipermail/lustre-devel-lustre.org/>
List-Post: <mailto:lustre-devel@lists.lustre.org>
List-Help: <mailto:lustre-devel-request@lists.lustre.org?subject=help>
List-Subscribe: <http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org>, 
 <mailto:lustre-devel-request@lists.lustre.org?subject=subscribe>
Cc: Lustre Development List <lustre-devel@lists.lustre.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Sebastien Buisson <sbuisson@ddn.com>

The ciphertext representation of the name of an encrypted file or
directory can be up to 256 bytes of binary data, if the cleartext
name is up to NAME_MAX. But then this ciphertext is encoded via
critical_encode() before being sent to servers. Once encoded, the
length can exceed NAME_MAX because of the escaped critical
characters.
So make sure ll_prep_md_op_data() accepts those too long encoded names
if it is called for lookup or create of an encrypted file or
directory. In the other cases, the 'name' taken as input is the plain
text version, so it must conform to the NAME_MAX limit.

When carrying out operations on an encrypted file with long name, we
manipulate a digested form whose hash needs to be matched against the
content of the LinkEA. The name found in the LinkEA is not NUL
terminated, so this aspect must be taken care of.

Fixes: e4c377fefc ("lustre: sec: filename encryption")
Fixes: 860818695d ("lustre: sec: filename encryption - digest support")
WC-bug-id: https://jira.whamcloud.com/browse/LU-13717
Lustre-commit: 75414af6bf310244d ("LU-13717 sec: fix handling of encrypted file with long name")
Signed-off-by: Sebastien Buisson <sbuisson@ddn.com>
Reviewed-on: https://review.whamcloud.com/45163
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Patrick Farrell <pfarrell@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/llite/llite_lib.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/lustre/llite/llite_lib.c b/fs/lustre/llite/llite_lib.c
index c9be5af..11a545a3 100644
--- a/fs/lustre/llite/llite_lib.c
+++ b/fs/lustre/llite/llite_lib.c
@@ -3110,7 +3110,9 @@ struct md_op_data *ll_prep_md_op_data(struct md_op_data *op_data,
 		if (namelen)
 			return ERR_PTR(-EINVAL);
 	} else {
-		if (namelen > ll_i2sbi(i1)->ll_namelen)
+		if ((!IS_ENCRYPTED(i1) ||
+		     (opc != LUSTRE_OPC_LOOKUP && opc != LUSTRE_OPC_CREATE)) &&
+		    namelen > ll_i2sbi(i1)->ll_namelen)
 			return ERR_PTR(-ENAMETOOLONG);
 
 		/* "/" is not valid name, but it's allowed */
-- 
1.8.3.1

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
