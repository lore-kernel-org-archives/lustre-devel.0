Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B11F6C02185
	for <lustre-devel@archiver.kernel.org>; Mon, 20 Jan 2025 04:54:23 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ybyfz62tTz1xS0;
	Sun, 19 Jan 2025 20:54:19 -0800 (PST)
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com
 [207.171.190.10])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ybyfv387rz1xFL
 for <lustre-devel@lists.lustre.org>; Sun, 19 Jan 2025 20:54:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1737348856; x=1768884856;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=2QUpN19rUIigj6EQQFYDEIWQXnGaCe8fWEKtGW8Mo5g=;
 b=KM/MCIEGXgBdpFvnqVl30wiz+nd9Ju9BBRHLLRrBVOBhq/9OpRf+YHu8
 wH98FyXlE/Q8hVWmbtc8jqSzPmpSrMGVxo5TPqWBmk4f7mT1RneEUryi9
 0PNtLR1RgTZsmmICXe/4xgthOhstzDL2BnlzHx0sfowowJXc1uWvVTv8k o=;
X-IronPort-AV: E=Sophos;i="6.13,218,1732579200"; d="scan'208";a="401979386"
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Received: from pdx4-co-svc-p1-lb2-vlan2.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.25.36.210])
 by smtp-border-fw-33001.sea14.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 20 Jan 2025 04:54:15 +0000
Received: from EX19MTAUEC001.ant.amazon.com [10.0.0.204:11244]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.38.161:2525]
 with esmtp (Farcaster)
 id 4d9f3ac7-abc6-4c73-a637-c37e8ef61602; Mon, 20 Jan 2025 04:54:13 +0000 (UTC)
X-Farcaster-Flow-ID: 4d9f3ac7-abc6-4c73-a637-c37e8ef61602
Received: from EX19D017UEA004.ant.amazon.com (10.252.134.70) by
 EX19MTAUEC001.ant.amazon.com (10.252.135.222) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 20 Jan 2025 04:54:13 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA004.ant.amazon.com (10.252.134.70) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 20 Jan 2025 04:54:13 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1258.039; Mon, 20 Jan 2025 04:54:13 +0000
From: "Day, Timothy" <timday@amazon.com>
To: Andreas Dilger <adilger@ddn.com>, NeilBrown <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Index: AQHbaUeBISfNkPD+x0KPSwDS4FyvbbMeyFEA
Date: Mon, 20 Jan 2025 04:54:12 +0000
Message-ID: <B22BAF52-E179-4C58-826F-5D3BD1121E4C@amazon.com>
References: <3139EEF5-91BF-4F8E-A112-1D66455AE3D2@amazon.com>
 <173716111777.22054.8452560203667698532@noble.neil.brown.name>
 <E4481869-E21A-4941-9A97-8C59B7104528@ddn.com>
In-Reply-To: <E4481869-E21A-4941-9A97-8C59B7104528@ddn.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.252.134.138]
Content-ID: <6F75B024544D414E86B46CCDA9687508@amazon.com>
MIME-Version: 1.0
Subject: Re: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
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
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

> This will definitely need some reorganization of files and directories in the
> Lustre source tree to align with the Linux kernel (e.g. moving everything
> under fs/lustre and net/lnet).

I think the Lustre tree ought to have a clearer separation between the
kernel code and user space. It should be pretty easy to shuffle the
directory structure to achieve this. We'd have something like:

fs/lustre/
net/lnet/lnet/
net/lnet/libcfs/
lustre_compat/ <- This gets compiled into libcfs
tests/
utils/

And eventually the fs/ and net/ would live in Linux mainline.
lustre_compat/ would remain to allow us to compile mainline
clients for older kernel, similar to AMDGPU (that I mentioned in
the other thread).

Another benefit of a cleaner split between kernel and user space:
older version of Lustre could definitely benefit from newer user space
features. Patrick's parallel migrate work comes to mind.

> That would probably be a question to get answered, whether LNet is
> "too Lustre specific" to be in net/ and should live in the Lustre tree?
>
> That would make it harder to backport patches to maintenance releases,
> but I'm hoping a script to rework pathnames in patches would be enough.

Newer versions of git are pretty good at finding directories after a relocation.
For example, if you pull down the upstream client branch and Lustre master
into the same repo, you can git cherry-pick a patch from one to the other and it
will automatically find the directories that contains the changed files. This
works even though the two repos don't share a common history.

If I created a patch to reorg Lustre, we could easily test some cherry-picks to
make sure they work right.

Tim Day

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
