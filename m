Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 8EEC8E674B8
	for <lustre-devel@archiver.kernel.org>; Mon, 22 Dec 2025 14:26:10 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4dZgQx3Qsvz20fW;
	Mon, 22 Dec 2025 06:25:29 -0800 (PST)
Received: from m16.mail.163.com (m16.mail.163.com [117.135.210.4])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4dZgQn0kD5z1xpC
 for <lustre-devel@lists.lustre.org>; Mon, 22 Dec 2025 06:25:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
 s=s110527; h=From:Content-Type:Mime-Version:Subject:Message-Id:
 Date:To; bh=5KRIS87KUNbEAB7oXJZnbORNUM6Ykg5XBj3uwoe8F4Q=; b=VOS/
 0gm2chGX3B0GxdSqUfmEoMBYvLAn8c2IBpJW9+Ogy7x6hPra0frfHDM0D/jhZM2o
 edP76JCflSFRZ99ge8I4Ug/H66uv7H63+spPNDq3GDnEpGSfQEpK78Y6dJ83+jGW
 /RReVA0SKgmfHtHnV/Ei7XQMpvOga+2InVm6b04=
Received: from smtpclient.apple (unknown [])
 by gzga-smtp-mtada-g1-2 (Coremail) with SMTP id
 _____wDn5rvKVElpgz0UBw--.20439S3; 
 Mon, 22 Dec 2025 22:25:15 +0800 (CST)
Mime-Version: 1.0 (Mac OS X Mail 16.0 \(3774.500.171.1.1\))
Message-Id: <D90D204A-12BA-430C-9731-73BBF95C0E5D@163.com>
Date: Mon, 22 Dec 2025 22:25:03 +0800
To: lustre-devel@lists.lustre.org
X-Mailer: Apple Mail (2.3774.500.171.1.1)
X-CM-TRANSID: _____wDn5rvKVElpgz0UBw--.20439S3
X-Coremail-Antispam: 1Uf129KBjvdXoWruryDGFWDAFWxuF1DZF18Xwb_yoWkJFgE9r
 ZIq3W29r4qyry3AF1rGwnxKr9rGwsagFyUZr10gF15XasrArn8Jrs8Cw17GFZ7A3srXF9r
 Gwn7t34fKr1j9jkaLaAFLSUrUUUUjb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
 9fnUUvcSsGvfC2KfnxnUUI43ZEXa7IUjWlkDUUUUU==
X-Originating-IP: [219.236.38.81]
X-CM-SenderInfo: xfdlwvhqjb6xrx6rljoofrz/xtbC5gvzSGlJVMsRCAAA3w
Subject: [lustre-devel] osp_md_index_it_next() may have a bug
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
From: caifengzhu via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: caifengzhu <caifeng_zhu@163.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Hi,

It seems osp_md_index_it_next() have a bug. Consider the case that 'ent' is non
null and points to the last entry in the current index page. In this case, a
new index page will be loaded with osp_it_next_page() and after the loading,
'ent' remains intact. The entry retrieving based on 'ent' is wrong.  Even
worse, it may cause kernel crash by accessing an unmaped page.

A simple fix may be like below.

diff --git a/lustre/osp/osp_md_object.c b/lustre/osp/osp_md_object.c
index 975249d498..88f3cb0002 100644
--- a/lustre/osp/osp_md_object.c
+++ b/lustre/osp/osp_md_object.c
@@ -663,7 +663,7 @@ static int osp_md_index_it_next(const struct lu_env *env, struct dt_it *di)
 {
        struct osp_it           *it = (struct osp_it *)di;
        struct lu_idxpage       *idxpage;
-       struct lu_dirent        *ent = (struct lu_dirent *)it->ooi_ent;
+       struct lu_dirent        *ent;
        int                     rc;
        ENTRY;

@@ -674,7 +674,7 @@ again:
                        RETURN(1);

                it->ooi_pos_ent++;
-               if (ent == NULL) {
+               if ((ent = (struct lu_dirent *)it->ooi_ent) == NULL) {
                        it->ooi_ent =
                              (struct lu_dirent *)idxpage->lip_entries;
                        RETURN(0);

Best Regards!
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
