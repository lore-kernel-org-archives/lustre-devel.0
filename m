Return-Path: <SRS0=NZgA=GY=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.5 required=3.0 tests=BAYES_00,DKIM_INVALID,
	DKIM_SIGNED,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4FDBC433E0
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 18:33:02 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 83FD423A40
	for <lustre-devel@archiver.kernel.org>; Thu, 21 Jan 2021 18:33:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 83FD423A40
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=casper.infradead.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id DE3A821F4C5;
	Thu, 21 Jan 2021 10:33:00 -0800 (PST)
Received: from casper.infradead.org (casper.infradead.org [90.155.50.34])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 879CF21F3B4
 for <lustre-devel@lists.lustre.org>; Thu, 21 Jan 2021 10:32:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
 d=infradead.org; s=casper.20170209; h=Sender:Content-Type:MIME-Version:
 Message-ID:Subject:To:From:Date:Reply-To:Cc:Content-Transfer-Encoding:
 Content-ID:Content-Description:In-Reply-To:References;
 bh=enFGlhYWAyouCGODBqX45YsiZyuTiEiuH0VrE7uC2ZI=; b=K/nmNvr7fORu1v042Lq1wpDqfv
 tFomRBUyZPcj0ONmWwqUnEX77c8jkXKl6c4UBEVNmvEbhStQsroYXMFKwyXddJs/rFZs9ohHPm/Ws
 1wrafjPtPjJzzPo3s+b87WIdv3OVUOTY8Q5JBTLbSq/ngXsNR1DipnZWvySyr9ufOqofvfamwgrYo
 xIgZpHjDB7zyswFW4Q8q1qxy55MNs2zVlXZNjlIlQ+RCLnAYE1OXMl0CdOEkPSptp6cHwmyEF7IbI
 YlfKQOvza5oNvicwA8kGLvCDsqQsZEWtlUGiLfwCNqCxA9uAQlu/5vWZehQlFmn/9WIlibKd5e6R9
 6CGYuyUw==;
Received: from jsimmons by casper.infradead.org with local (Exim 4.94 #2 (Red
 Hat Linux)) id 1l2ekq-00HNY0-D8
 for lustre-devel@lists.lustre.org; Thu, 21 Jan 2021 18:32:41 +0000
Date: Thu, 21 Jan 2021 18:32:24 +0000
From: James Simmons <jsimmons@casper.infradead.org>
To: Lustre-devel <lustre-devel@lists.lustre.org>
Message-ID: <20210121183224.GA4134678@casper.infradead.org>
MIME-Version: 1.0
Content-Disposition: inline
Subject: [lustre-devel] Using generic radix trees for large allocations
X-BeenThere: lustre-devel@lists.lustre.org
X-Mailman-Version: 2.1.23
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

  One of the challenging issues for very large scale file systems is the
performance crash when you cross about 670 stripe count. This is due to
the memory allocations going from kmalloc to vmalloc. Once you start to
use vmalloc to allocate the ptlrpc message buffers all the allocating
start to serialize on a global spinlock.
  Looking for a solution the best one I found so far have been using the
generic radix tree API. You have to allocate a page worth of data at a
time so its cluncky for use but I think we could make it work. What do
you think?

https://www.kernel.org/doc/html/latest/core-api/generic-radix-tree.html
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
