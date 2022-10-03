Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 3300DC433F5
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Oct 2022 06:52:24 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Mgs2w46J8z1wdk;
	Sun,  2 Oct 2022 23:52:24 -0700 (PDT)
Received: from mail.hpc2n.umu.se (molasses.hpc2n.umu.se [130.239.45.242])
 (using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Mgs2s69KRz1wYk
 for <lustre-devel@lists.lustre.org>; Sun,  2 Oct 2022 23:52:21 -0700 (PDT)
Received: from [IPV6:2001:6b0:e:4a46:571e:6e9:1682:8414] (unknown
 [IPv6:2001:6b0:e:4a46:571e:6e9:1682:8414])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits))
 (No client certificate requested) (Authenticated sender: ake)
 by mail.hpc2n.umu.se (Postfix) with ESMTPSA id DA62E11B06
 for <lustre-devel@lists.lustre.org>; Mon,  3 Oct 2022 08:52:18 +0200 (CEST)
Message-ID: <21061178-bc35-8d8e-e741-ad2046a1b3c2@hpc2n.umu.se>
Date: Mon, 3 Oct 2022 08:52:18 +0200
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:91.0) Gecko/20100101
 Thunderbird/91.11.0
To: lustre-devel@lists.lustre.org
Content-Language: en-US
From: =?UTF-8?Q?=c3=85ke_Sandgren?= <ake.sandgren@hpc2n.umu.se>
Subject: [lustre-devel] review.whamcloud down or me being kicked out?
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

Hi!

Just trying to push to review, but get
===
ssh: connect to host review.whamcloud.com port 29418: Connection refused
fatal: Could not read from remote repository.

Please make sure you have the correct access rights
and the repository exists.
===

It's been a while since I did this the last time so I might have been 
kicked out.

-- 
Ake Sandgren, HPC2N, Umea University, S-90187 Umea, Sweden
Internet: ake@hpc2n.umu.se  Mobile: +46 70 7716134  Fax: +46 90-580 14
WWW: http://www.hpc2n.umu.se
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
