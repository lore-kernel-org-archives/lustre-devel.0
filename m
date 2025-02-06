Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7EFA6C02199
	for <lustre-devel@archiver.kernel.org>; Thu,  6 Feb 2025 18:37:07 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ypm6D5bBzz1wWh;
	Thu, 06 Feb 2025 10:36:52 -0800 (PST)
Received: from smtp-fw-52002.amazon.com (smtp-fw-52002.amazon.com
 [52.119.213.150])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ypm6020wcz1wLw
 for <lustre-devel@lists.lustre.org>; Thu, 06 Feb 2025 10:36:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1738867000; x=1770403000;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=HqFaimuLXXjXVf4VESjlHNV3+/3fUpjqTOUFgWXFKWc=;
 b=biuJVrU9Kukzj3FLCuHoemJL4RM7FNrWFqS5WVO0Gg1dGmjKaK3fpuH1
 86BYFrzsrfVxmyZmZD6h9R06JZsYWf3pBSgSeBTUr9xH+7zB53XAnlKgS
 dEA98MHv8a4sC4emYRsKwPzflawQ1wtaLOiZZCkpxh2Wr+oFScAuaLj0I k=;
X-IronPort-AV: E=Sophos;i="6.13,265,1732579200"; d="scan'208";a="694997158"
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.43.8.6])
 by smtp-border-fw-52002.iad7.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 06 Feb 2025 18:36:37 +0000
Received: from EX19MTAUEC001.ant.amazon.com [10.0.44.209:28904]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.5.114:2525]
 with esmtp (Farcaster)
 id 73caaef9-7409-43c7-8cfc-1fd8e6fc4f39; Thu, 6 Feb 2025 18:36:37 +0000 (UTC)
X-Farcaster-Flow-ID: 73caaef9-7409-43c7-8cfc-1fd8e6fc4f39
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19MTAUEC001.ant.amazon.com (10.252.135.222) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Thu, 6 Feb 2025 18:36:36 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA001.ant.amazon.com (10.252.134.93) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Thu, 6 Feb 2025 18:36:36 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1258.039; Thu, 6 Feb 2025 18:36:36 +0000
From: "Day, Timothy" <timday@amazon.com>
To: Andreas Dilger <adilger@ddn.com>, Oleg Drokin <green@whamcloud.com>
Thread-Index: AQHbdQC60jpqmvximka6OK5s2qgm4LM1gz+AgAB6TAD//7QUAIAAV7kAgAABagCAAWD5AIAAEiWAgAEkiICAAavegA==
Date: Thu, 6 Feb 2025 18:36:36 +0000
Message-ID: <11E4B1AF-3C2A-4E9A-8847-BA319ED6C301@amazon.com>
References: <4243d258f1a38e8539e88a68fb705f05bf18dfb1.camel@whamcloud.com>
 <3B83582B-2D34-4D54-97AF-67E36E93FF74@ddn.com>
In-Reply-To: <3B83582B-2D34-4D54-97AF-67E36E93FF74@ddn.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.106.239.32]
Content-ID: <840FE556968FE2438CDA0AB6B6FB9153@amazon.com>
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
Cc: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

> To better cover the skew between different VMs running different subtests, we could change the test-framework code to run the subtests in different order (either starting at a random offset, or in random order).
>
> This would also expose some hidden assumptions and dependencies in the subtests themselves, so that would need to be fixed to avoid false test failures, but the main goal of the boilpot testing is finding crashes/deadlocks, so if a few tests fail because of minor test issues I don't think that is a blocker.
>
>
> Cheers, Andreas

We could also limit each VM to run a subset of the sanity tests. Then
we could cap the length of the longest run test. I have some scripting
magic already to divide up the subtests between VMs.

Tim Day

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
