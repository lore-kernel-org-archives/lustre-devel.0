Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 7B51EC4332F
	for <lustre-devel@archiver.kernel.org>; Thu,  3 Nov 2022 20:09:38 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4N3FD15SYlz1yGQ;
	Thu,  3 Nov 2022 13:07:29 -0700 (PDT)
Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com [52.95.49.90])
 (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256
 bits)) (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4N3FCm61gyz1yFt
 for <lustre-devel@lists.lustre.org>; Thu,  3 Nov 2022 13:07:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
 t=1667506037; x=1699042037; h=from:to:subject:date:message-id:
 content-transfer-encoding:mime-version;
 bh=zsl6RtKkzKZwX47cFnAd+la+zRwTFvRoa+7mZ9LavtQ=;
 b=TCvQMPdJUjfdQM6lynzvX50dLdTrX/Nszx8QGSQpYp2E3TnaLvfaH2WQ
 nl8Op82W6+yKywvUdt9AIwcm0WiEhWLTTiIb2enlrp8F7pksc4T+tvqnK
 ETcv6iHNZOv3ZFesQjB35zjGAJawIBxuGnL75eB4wbCWDHBpRlRLpTKCU E=;
X-IronPort-AV: E=Sophos;i="5.96,135,1665446400"; d="scan'208";a="262968244"
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO
 email-inbound-relay-iad-1d-m6i4x-d7759ebe.us-east-1.amazon.com) ([10.43.8.6])
 by smtp-border-fw-6002.iad6.amazon.com with
 ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 03 Nov 2022 20:07:09 +0000
Received: from EX13D22EUA001.ant.amazon.com
 (iad12-ws-svc-p26-lb9-vlan2.iad.amazon.com [10.40.163.34])
 by email-inbound-relay-iad-1d-m6i4x-d7759ebe.us-east-1.amazon.com (Postfix)
 with ESMTPS id 34E1241D29; Thu,  3 Nov 2022 20:07:07 +0000 (UTC)
Received: from EX19D007EUA002.ant.amazon.com (10.252.50.68) by
 EX13D22EUA001.ant.amazon.com (10.43.165.37) with Microsoft SMTP Server (TLS)
 id 15.0.1497.42; Thu, 3 Nov 2022 20:07:07 +0000
Received: from EX19D007EUA004.ant.amazon.com (10.252.50.76) by
 EX19D007EUA002.ant.amazon.com (10.252.50.68) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1118.15; Thu, 3 Nov 2022 20:07:06 +0000
Received: from EX19D007EUA004.ant.amazon.com ([fe80::30f7:c558:653e:6ed9]) by
 EX19D007EUA004.ant.amazon.com ([fe80::30f7:c558:653e:6ed9%3]) with
 mapi id 15.02.1118.015; Thu, 3 Nov 2022 20:07:06 +0000
To: "Simmons, James" <simmonsja@ornl.gov>, "lustre-devel@lists.lustre.org"
 <lustre-devel@lists.lustre.org>
Thread-Topic: [lustre-devel] lnet selftest using large NIDs (16 byte)
Thread-Index: Adjvv9UCmT+HlazVRwSsFHagqSEvvA==
Date: Thu, 3 Nov 2022 20:07:06 +0000
Message-ID: <f24018236ca04439b556c6beb7a25d5d@amazon.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-originating-ip: [10.85.143.175]
MIME-Version: 1.0
Subject: [lustre-devel] lnet selftest using large NIDs (16 byte)
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
From: "Yitschak, Yehuda via lustre-devel" <lustre-devel@lists.lustre.org>
Reply-To: "Yitschak, Yehuda" <yehuday@amazon.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>


>     There is no support for this work in 2.12. You are going to have to move to a
> newer lustre version. LND forward
>     porting shouldn't be to painful. The biggest change is the LNet health work
> but it's not a hard requirement.
>     What will need to be changed is support for the large nid support. By that I
> mean moving from
> 
>    lnet_nid_t  -> struct lnet_nid
> 
>    The port will be easier than you think.
> 

Thanks for clarifying. By hacking the addressing I mean I use 4 bytes NID and just patch the address in the LND.
Last time I moved Lustre versions my main issues was with the build and install process, not the actual rebase
I found it challenging to build lustre for my specific kernel and Distro. 
Anyway, I'll give a try and see how it goes.
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
