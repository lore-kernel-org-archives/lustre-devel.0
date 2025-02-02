Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 43A28C0218F
	for <lustre-devel@archiver.kernel.org>; Sun,  2 Feb 2025 21:07:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmMGW1qSlz21H7;
	Sun, 02 Feb 2025 12:50:43 -0800 (PST)
Received: from smtp4.ccs.ornl.gov (smtp4.ccs.ornl.gov [160.91.203.40])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmMF15hV3z20yt
 for <lustre-devel@lists.lustre.org>; Sun, 02 Feb 2025 12:49:25 -0800 (PST)
Received: from star2.ccs.ornl.gov (ltm-e204-208.ccs.ornl.gov [160.91.203.12])
 by smtp4.ccs.ornl.gov (Postfix) with ESMTP id 09447182372;
 Sun,  2 Feb 2025 15:46:42 -0500 (EST)
Received: by star2.ccs.ornl.gov (Postfix, from userid 2004)
 id 0823D106BE18; Sun,  2 Feb 2025 15:46:42 -0500 (EST)
From: James Simmons <jsimmons@infradead.org>
To: Andreas Dilger <adilger@whamcloud.com>, Oleg Drokin <green@whamcloud.com>,
 NeilBrown <neilb@suse.de>
Date: Sun,  2 Feb 2025 15:46:26 -0500
Message-ID: <20250202204633.1148872-27-jsimmons@infradead.org>
X-Mailer: git-send-email 2.43.5
In-Reply-To: <20250202204633.1148872-1-jsimmons@infradead.org>
References: <20250202204633.1148872-1-jsimmons@infradead.org>
MIME-Version: 1.0
Subject: [lustre-devel] [PATCH 26/33] lustre: mdc: md_open_data should keep
 ref on close_req
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.39
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
Cc: Lai Siyao <lai.siyao@whamcloud.com>, Li Dongyang <dongyangli@ddn.com>,
 Lustre Development List <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

From: Li Dongyang <dongyangli@ddn.com>

md_open_data should keep a ref on mod_close_req,
otherwise the mod_close_req could be freed before
we try to access mod_close_req via md_open_data.

WC-bug-id: https://jira.whamcloud.com/browse/LU-16745
Lustre-commit: ca716f763f89af192 ("LU-16745 mdc: md_open_data should keep ref on close_req")
Signed-off-by: Li Dongyang <dongyangli@ddn.com>
Reviewed-on: https://review.whamcloud.com/c/fs/lustre-release/+/50656
Reviewed-by: Andreas Dilger <adilger@whamcloud.com>
Reviewed-by: Lai Siyao <lai.siyao@whamcloud.com>
Reviewed-by: Oleg Drokin <green@whamcloud.com>
Signed-off-by: James Simmons <jsimmons@infradead.org>
---
 fs/lustre/include/obd.h     | 2 ++
 fs/lustre/mdc/mdc_request.c | 4 ++++
 2 files changed, 6 insertions(+)

diff --git a/fs/lustre/include/obd.h b/fs/lustre/include/obd.h
index c62d9171150a..604739ca92c2 100644
--- a/fs/lustre/include/obd.h
+++ b/fs/lustre/include/obd.h
@@ -1188,6 +1188,8 @@ static inline struct md_open_data *obd_mod_alloc(void)
 	if (atomic_dec_and_test(&(mod)->mod_refcount)) {		\
 		if ((mod)->mod_open_req)				\
 			ptlrpc_req_finished((mod)->mod_open_req);	\
+		if ((mod)->mod_close_req)				\
+			ptlrpc_req_finished((mod)->mod_close_req);	\
 		kfree(mod);						\
 	}								\
 })
diff --git a/fs/lustre/mdc/mdc_request.c b/fs/lustre/mdc/mdc_request.c
index 2b8386661a31..3b838bceba39 100644
--- a/fs/lustre/mdc/mdc_request.c
+++ b/fs/lustre/mdc/mdc_request.c
@@ -1033,12 +1033,16 @@ static int mdc_close(struct obd_export *exp, struct md_op_data *op_data,
 	if (mod) {
 		if (rc != 0)
 			mod->mod_close_req = NULL;
+		if (mod->mod_close_req)
+			ptlrpc_request_addref(mod->mod_close_req);
+
 		/* Since now, mod is accessed through open_req only,
 		 * thus close req does not keep a reference on mod anymore.
 		 */
 		obd_mod_put(mod);
 	}
 	*request = req;
+
 	return rc < 0 ? rc : saved_rc;
 }
 
-- 
2.39.3

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
