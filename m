Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 0B8CEC7115B
	for <lustre-devel@archiver.kernel.org>; Fri, 20 Jun 2025 20:26:01 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4bP8BB5jvCz1wdt;
	Fri, 20 Jun 2025 13:25:54 -0700 (PDT)
Received: from smtp-fw-9105.amazon.com (smtp-fw-9105.amazon.com
 [207.171.188.204])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4bP8B95MK8z1wC9
 for <lustre-devel@lists.lustre.org>; Fri, 20 Jun 2025 13:25:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazoncorp2;
 t=1750451154; x=1781987154;
 h=from:to:cc:date:message-id:references:in-reply-to:
 content-id:content-transfer-encoding:mime-version:subject;
 bh=fQD0M8toiwVZY2LSEbEaG7G3vF5UFe3oqus47GfeDhg=;
 b=TfsLODb9eW42BpEaU1Xm+VKcEidF4lI2bQIb+dUNznWAYj57wdcXr6zH
 81JNw4nRIUtmXCtwwVKirpEN2YDXzz2WfmU2A4wuIu1/dfW0wu70xrDoR
 rGAYoBt3SFgqFDg3E1B2JkkBz5xWWRWwxEryrQCwtLwQ7IzNksQra5Kfu
 oZhtORGLjMKfn015HPVzlHbExDgqKrPmnqM4qBC14EGLsBXXBywfVt5NJ
 7ZdmH/wV2c+gEpSWB37/rJDqyuE3nGDiHICm5uvp4AoZs1kDLy/+b8aMJ
 h8Fr4H4FULikYojSJ0N5Wk+TS1f9ZiReQd8ptjmY9FE+stWdWvUkRs303 g==;
X-IronPort-AV: E=Sophos;i="6.16,252,1744070400"; d="scan'208";a="32981988"
Thread-Topic: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
Received: from pdx4-co-svc-p1-lb2-vlan2.amazon.com (HELO
 smtpout.prod.us-east-1.prod.farcaster.email.amazon.dev) ([10.25.36.210])
 by smtp-border-fw-9105.sea19.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 20 Jun 2025 20:25:53 +0000
Received: from EX19MTAUEA002.ant.amazon.com [10.0.0.204:55713]
 by smtpin.naws.us-east-1.prod.farcaster.email.amazon.dev [10.0.60.181:2525]
 with esmtp (Farcaster)
 id 1b6361f0-1ac7-41fb-8403-5a79ed895b9c; Fri, 20 Jun 2025 20:25:52 +0000 (UTC)
X-Farcaster-Flow-ID: 1b6361f0-1ac7-41fb-8403-5a79ed895b9c
Received: from EX19D017UEA002.ant.amazon.com (10.252.134.77) by
 EX19MTAUEA002.ant.amazon.com (10.252.134.9) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1544.14;
 Fri, 20 Jun 2025 20:25:52 +0000
Received: from EX19D017UEA001.ant.amazon.com (10.252.134.93) by
 EX19D017UEA002.ant.amazon.com (10.252.134.77) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1544.14;
 Fri, 20 Jun 2025 20:25:51 +0000
Received: from EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed]) by
 EX19D017UEA001.ant.amazon.com ([fe80::bffb:623f:af5e:ebed%3]) with
 mapi id 15.02.1544.014; Fri, 20 Jun 2025 20:25:51 +0000
From: "Day, Timothy" <timday@amazon.com>
To: Xose Vazquez Perez <xose.vazquez@gmail.com>
CC: LUSTRE DEVEL ML <lustre-devel@lists.lustre.org>
Thread-Index: AQHb4h2pYmSgQcYOiESoAFFkmm94a7QMO76A
Date: Fri, 20 Jun 2025 20:25:51 +0000
Message-ID: <2698F449-3C9E-4934-980D-619A013EE51D@amazon.com>
References: <20250620195720.59870-1-xose.vazquez@gmail.com>
In-Reply-To: <20250620195720.59870-1-xose.vazquez@gmail.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.252.141.13]
Content-ID: <3E1D934367F71546AF1D8730D81B963F@amazon.com>
MIME-Version: 1.0
Subject: Re: [lustre-devel] [PATCH 1/2] lustre: refresh FSF licences
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

The license text is copied verbatim from the Linux kernel [1]. I think
we should stay aligned with that. Also, Lustre uses Gerrit to submit
patches. I've linked the wiki with instructions on the current process.

Tim Day

[1] https://github.com/torvalds/linux/tree/master/LICENSES/preferred
[2] https://wiki.lustre.org/Submitting_Changes

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
