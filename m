Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 17E51C02192
	for <lustre-devel@archiver.kernel.org>; Mon,  3 Feb 2025 20:14:32 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YmyLy3Wjsz1xRl;
	Mon, 03 Feb 2025 12:11:38 -0800 (PST)
Received: from smtp-fw-9102.amazon.com (smtp-fw-9102.amazon.com
 [207.171.184.29])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4YmyLf062Vz1xPj
 for <lustre-devel@lists.lustre.org>; Mon, 03 Feb 2025 12:11:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1738613483; x=1770149483;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=me7fJT5N+5RHac/o/jX9rZ4YR2EzCbs78y4q4ADrAHc=;
 b=RZans7UPfmMAueD0IzroCn89k12uqprEwrp6jPU2e1cJVBZSYW/0uU5F
 msNJsHr5l4prFqd3U/PPpCH37R8TkeHZ8iaAG+vQiCVySfpZiMUPPoX2f
 MdLtRdFlEfpe2g6jNuVrXWLTRQA0qUmnhjqCUXuUAzn2UALtAXAcoIqPM Y=;
X-IronPort-AV: E=Sophos;i="6.13,256,1732579200"; d="scan'208";a="490817827"
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Received: from pdx4-co-svc-p1-lb2-vlan3.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.25.36.214])
 by smtp-border-fw-9102.sea19.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Feb 2025 20:10:55 +0000
Received: from EX19MTAUEA002.ant.amazon.com [10.0.44.209:13095]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.84.172:2525]
 with esmtp (Farcaster)
 id c719589f-5240-481c-b67b-fd7e7d3a362f; Mon, 3 Feb 2025 20:10:53 +0000 (UTC)
X-Farcaster-Flow-ID: c719589f-5240-481c-b67b-fd7e7d3a362f
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19MTAUEA002.ant.amazon.com (10.252.134.9) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 3 Feb 2025 20:10:53 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA001.ant.amazon.com (10.252.134.93) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Mon, 3 Feb 2025 20:10:53 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1258.039; Mon, 3 Feb 2025 20:10:53 +0000
From: "Day, Timothy" <timday@amazon.com>
To: Oleg Drokin <green@whamcloud.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Index: AQHbdQC60jpqmvximka6OK5s2qgm4LM1gz+AgAB6TAD//7QUAA==
Date: Mon, 3 Feb 2025 20:10:53 +0000
Message-ID: <6F2B1870-F031-429B-8257-730845B6E18F@amazon.com>
References: <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
 <173844834301.22054.134358817491003595@noble.neil.brown.name>
 <82e4528eb0f4961bdc6b065dfcabea03c1a9face.camel@whamcloud.com>
 <AFA09EE9-0679-4484-8571-F03F7DEE20EC@amazon.com>
 <3ce0efd54f2bf45e84882de0e1b469caf1f74397.camel@whamcloud.com>
In-Reply-To: <3ce0efd54f2bf45e84882de0e1b469caf1f74397.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.252.141.28]
Content-ID: <E6BC624FCD3E434ABBDC13287656F85C@amazon.com>
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

> Unfortunately cloud is not very conductive to the way boilpot operates,
> the whole idea is to instantiate a gazillion of virtual machines that
> are run on a single physical host to overcommit the cpu (a lot!)
>
> so I have this 2T RAM AMD box and I instantiate 240 virtual machines on
> it, each gets 15G RAM and 15 CPU cores (this is the important part, if
> you do not have cpu overcommit, nothing works)

You can do a similar thing in the cloud with bare metal instances. Normally,
you can't do nested virtualization (i.e. QEMU/KVM inside EC2). But a bare
metal instance avoids that issue. That's how I run ktest [1], which uses
QEMU/KVM. Something like m7a.metal-48xl has 192 CPU and 768G of
memory, so similar to the size you mention. What ratio of overcommit
do you have? For RAM, it seems to be 2:1. What about for CPU?

Tim Day

[1] https://github.com/koverstreet/ktest/tree/master

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
