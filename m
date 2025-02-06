Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 11359C02199
	for <lustre-devel@archiver.kernel.org>; Thu,  6 Feb 2025 18:24:57 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4YplrN2vsXz1wVt;
	Thu, 06 Feb 2025 10:24:52 -0800 (PST)
Received: from smtp-fw-9106.amazon.com (smtp-fw-9106.amazon.com
 [207.171.188.206])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Yplqs6vNrz1wLw
 for <lustre-devel@lists.lustre.org>; Thu, 06 Feb 2025 10:24:25 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1738866266; x=1770402266;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=3jU5EIMAiRxtrIwTXcabbYB2UvUgGN0ogh87c9ku0b8=;
 b=gruCaU6bDzVl58yrfvsvbylGBT0Jn7suVmzKylWIWSIw3sHXtJhohtHU
 N9HDbmPIUne7WOtelXrEmDkIJIrAk6rhOxIAly2D3nje7SGaIQwYV+SEe
 KktucoAqu6tliVfEkczIWMQUCcdfSl0CjYPXjYi7Tkcxpw77gYvfe8Xnj A=;
X-IronPort-AV: E=Sophos;i="6.13,264,1732579200"; d="scan'208";a="796703956"
Thread-Topic: [lustre-devel] [LSF/MM/BPF TOPIC] [DRAFT] Lustre client
 upstreaming
Received: from pdx4-co-svc-p1-lb2-vlan2.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.25.36.210])
 by smtp-border-fw-9106.sea19.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 06 Feb 2025 18:24:26 +0000
Received: from EX19MTAUEB001.ant.amazon.com [10.0.29.78:42738]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.50.106:2525]
 with esmtp (Farcaster)
 id d94d6eea-a157-4d72-88cf-89af7e0df6cb; Thu, 6 Feb 2025 18:24:24 +0000 (UTC)
X-Farcaster-Flow-ID: d94d6eea-a157-4d72-88cf-89af7e0df6cb
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19MTAUEB001.ant.amazon.com (10.252.135.108) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Thu, 6 Feb 2025 18:24:24 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA001.ant.amazon.com (10.252.134.93) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.39;
 Thu, 6 Feb 2025 18:24:24 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1258.039; Thu, 6 Feb 2025 18:24:24 +0000
From: "Day, Timothy" <timday@amazon.com>
To: Oleg Drokin <green@whamcloud.com>, "neilb@suse.de" <neilb@suse.de>
CC: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Thread-Index: AQHbdQC60jpqmvximka6OK5s2qgm4LM1gz+AgAB6TAD//7QUAIAAV7kAgARBhYA=
Date: Thu, 6 Feb 2025 18:24:24 +0000
Message-ID: <0CA3103F-1578-4AE5-9260-E95ED38139DE@amazon.com>
References: <d008c14bba74e39999ae70af871740a5d0c5c6eb.camel@whamcloud.com>
 <173844834301.22054.134358817491003595@noble.neil.brown.name>
 <82e4528eb0f4961bdc6b065dfcabea03c1a9face.camel@whamcloud.com>
 <AFA09EE9-0679-4484-8571-F03F7DEE20EC@amazon.com>
 <3ce0efd54f2bf45e84882de0e1b469caf1f74397.camel@whamcloud.com>
 <6F2B1870-F031-429B-8257-730845B6E18F@amazon.com>
 <3285ff88995a57ec6c01917c608519c5a7d0f78c.camel@whamcloud.com>
In-Reply-To: <3285ff88995a57ec6c01917c608519c5a7d0f78c.camel@whamcloud.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.106.239.32]
Content-ID: <C82F01722EC848459BC8C404751685C5@amazon.com>
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

> don't really need memory overcommit (in fact it's somewhat
> counterproductive), but since VMs typically don't use all RAM I wing it
> and run somewhat more VMs than what memory permits.
>
> as for CPU - the more overcommit is the better (my box has 96 cores).

Thanks for the pointers. Not sure which instance type I'd use, but
it's easy enough to try a bunch and see what works best.

> if this is to be deployed in the cloud at will, some robust
> orchestration is needed host-side - I create 240 libvirt driven VMs
> with their own storage in LVM, dhcp-driven autoconf, nfs export host-
> side with the right distro - just once per box lifetime and compiled
> lustre every time I run testing (so a resh checkout of master-next
> usually).
> Then configure crashdumping and an inotifywatch-based script to catch
> cores and do some light processign and ship results to the central data
> collector. (might be more efficient to do using in-vm crashdumping
> instead?)

I wrote a parallel ktest runner [1] a while back that probably does
the needed orchestration on the host side. It was originally intended
to run sanity tests faster (mostly for the OSD stuff I was working on).
But I think it could be adapted to run boilpot without much work.
It'd probably need some daemonize mode and I'd need to validate
that ktest actually captures all of the error modes we care about.

Ideally, the boilpot part would be platform agnostic. The cloud
orchestration part would just create the VM, run boilpot, and shuffle
the crash dumps off the box. My main goal (right now) is to get
something easily reproducible and get a sense of the signal/noise
ratio on boilpot. Plus, it might be interesting to try and flush out bugs
in my OSD as well [2]. It's hard to say how often I'd run it without
first seeing how effective it is.

Tim Day

[1] https://github.com/tim-day-387/ktest/tree/pktest
[2] https://review.whamcloud.com/c/fs/lustre-release/+/55594


_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
