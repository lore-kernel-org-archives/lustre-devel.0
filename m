Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C2B1FC02196
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Feb 2025 17:29:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Ymtm60wSTz20v1;
	Mon, 03 Feb 2025 09:29:42 -0800 (PST)
Received: from smtp-fw-6001.amazon.com (smtp-fw-6001.amazon.com [52.95.48.154])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Ymtfc6Zptz20ws
 for <lustre-devel@lists.lustre.org>; Mon, 03 Feb 2025 09:24:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1738603497; x=1770139497;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=mmBWhoMcsUFfOnxt4v0jqJ+EsInrQCEa0LTzytNMYkg=;
 b=CsY/0cuIXOrgqb7mmzl+FXI4paaat6SJTzqPcKDvXnBF7SPD0itLlifw
 VaDKPsrZw1BYrXnQ0Kocdjg/Zk3Csb8sYgXjw+DSvIGfOmQMxV3yOtPG6
 QAMQYyZqWhUMGft7Zo5KB3lc2oJKlVI+rjJ6ISV5DdiJiGf+zW6iV1tZc Y=;
X-IronPort-AV: E=Sophos;i="6.13,256,1732579200"; d="scan'208";a="459252343"
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Received: from iad12-co-svc-p1-lb1-vlan2.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.43.8.2])
 by smtp-border-fw-6001.iad6.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Feb 2025 17:24:55 +0000
Received: from EX19MTAUEA002.ant.amazon.com [10.0.44.209:43675]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.38.255:2525]
 with esmtp (Farcaster)
 id a6f84d25-7cc7-47a4-94d7-1cf2f4976003; Mon, 3 Feb 2025 17:24:54 +0000 (UTC)
X-Farcaster-Flow-ID: a6f84d25-7cc7-47a4-94d7-1cf2f4976003
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19MTAUEA002.ant.amazon.com (10.252.134.9) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 3 Feb 2025 17:24:54 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA001.ant.amazon.com (10.252.134.93) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 3 Feb 2025 17:24:54 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1258.039; Mon, 3 Feb 2025 17:24:54 +0000
From: "Day, Timothy" <timday@amazon.com>
To: Oleg Drokin <green@whamcloud.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Index: AQHbdQC60jpqmvximka6OK5s2qgm4LM1gz+A
Date: Mon, 3 Feb 2025 17:24:54 +0000
Message-ID: <AFA09EE9-0679-4484-8571-F03F7DEE20EC@amazon.com>
References: <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
 <173844834301.22054.134358817491003595@noble.neil.brown.name>
 <82e4528eb0f4961bdc6b065dfcabea03c1a9face.camel@whamcloud.com>
In-Reply-To: <82e4528eb0f4961bdc6b065dfcabea03c1a9face.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.252.141.28]
Content-ID: <417F732B6A432241808BCA7EC995D67E@amazon.com>
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

> If you want to avoid surprises for your patches, I can publish my
> boilpot scripts and you can run your own instance if you have the
> hardware.
> Or we can find some sponsors to have some sort of a shared public
> instance where people could drop their patches to?

If you could publish the boilpot scripts, I think that'd be super helpful.
It'd be a lot easier to understand how to reproduce these failures.
Plus, writing the orchestration to run it in the cloud would be
straightforward, I think.

Tim Day

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
