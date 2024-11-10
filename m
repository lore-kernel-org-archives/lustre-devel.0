Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id A2CFAD5E38A
	for <lustre-devel@archiver.kernel.org>; Sun, 10 Nov 2024 01:07:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XmF0D24Ldz1xBt;
	Sat, 09 Nov 2024 17:07:40 -0800 (PST)
Received: from mail.someonex.net (mail.someonex.net [5.2.76.123])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XmF096QGSz1wMp
 for <lustre-devel@lists.lustre.org>; Sat, 09 Nov 2024 17:07:37 -0800 (PST)
Message-ID: <435e4ec8-35b7-4a23-8924-70607d90d654@someonex.net>
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=someonex.net;
 s=mail; t=1731200855;
 bh=EOd11rUw9L6+9/xe05LyrcrveeKDexAT/tI4+6bOn10=;
 h=Date:To:From:Subject;
 b=cTjSJXkfE1OTKdd8yBqpQ1XXFjpwpZ12Zti62oED6AEm1wia0S10cV63gWuZvXX9t
 NM61un58r8MUQax+AVO86aISbjJtN5Fo0CsivciCc94gdWd3fBRCFoBF+bihTLfXq2
 Wee65i+Mxv873BVYN6M6aTGlzng+jzUBXJhuC0Pk=
Date: Sun, 10 Nov 2024 01:07:34 +0000
MIME-Version: 1.0
Content-Language: en-US
To: lustre-devel@lists.lustre.org
From: Else Someone <else@someonex.net>
Organization: someonex.net
Subject: [lustre-devel] mke2fs supported features: dirdata
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
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Hello again! I posted here earlier about my attempts at building Lustre 
with Nix. There was another issue I was struggling with, related to 
e2fsprogs, that I thought I should ask here if I was supposed to patch 
it too?


My mkfs.lustre (ldiskfs) is failing with mke2fs complaining about an 
"incompatible option set". Specifically it's complaining about the 
option `dirdata`. Looking at e2fsprogs' sources, 
`EXT4_FEATURE_INCOMPAT_DIRDATA` isn't listed in `ok_features` in 
`misc/mke2fs.c`. Even if I add it there, mke2fs fails later at 
`ext2fs_initialize`. I was surprised not to find any error reports in 
jira concerning dirdata specifically (there were similar errors reported 
for e.g. large_dir), surely I must be doing something wrong.


Do I have to patch e2fsprogs?


Do tell me if I'm being too noisy or if there's a better channel for 
this sort of questions. I actually have a few more, should I ask each in 
a separate thread or should I aggregate all under one SUBJECT?


Thanks

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
