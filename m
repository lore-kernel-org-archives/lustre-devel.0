Return-Path: <SRS0=689L=MD=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBB04C11F66
	for <lustre-devel@archiver.kernel.org>; Sun, 11 Jul 2021 15:10:00 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id D2C46610F7
	for <lustre-devel@archiver.kernel.org>; Sun, 11 Jul 2021 15:09:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2C46610F7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=devyard.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 6774B21CAB7;
	Sun, 11 Jul 2021 08:09:59 -0700 (PDT)
Received: from 9.mo68.mail-out.ovh.net (9.mo68.mail-out.ovh.net
 [46.105.78.111])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id C234D21CA30
 for <lustre-devel@lists.lustre.org>; Sun, 11 Jul 2021 08:09:56 -0700 (PDT)
Received: from player157.ha.ovh.net (unknown [10.109.143.146])
 by mo68.mail-out.ovh.net (Postfix) with ESMTP id 3D5E71A407F
 for <lustre-devel@lists.lustre.org>; Sun, 11 Jul 2021 17:09:55 +0200 (CEST)
Received: from devyard.org (unknown [213.10.167.74])
 (Authenticated sender: ashpy@devyard.org)
 by player157.ha.ovh.net (Postfix) with ESMTPSA id 9500F2024647A
 for <lustre-devel@lists.lustre.org>; Sun, 11 Jul 2021 15:09:54 +0000 (UTC)
Authentication-Results: garm.ovh; auth=pass
 (GARM-99G0033df06819-0fe7-4c7f-83b0-e4972d2d159c,
 6F597CDCCB51BCBE1F71DAFA5B30CC078FF7F13D) smtp.auth=ashpy@devyard.org
X-OVh-ClientIp: 213.10.167.74
Mime-Version: 1.0
From: "Quentin Bouget" <ypsah@devyard.org>
To: <lustre-devel@lists.lustre.org>
Date: Sun, 11 Jul 2021 17:05:32 +0200
Message-Id: <CCQEJJD9M6WG.1MWUN8FBI1MQ2@dobby>
X-Ovh-Tracer-Id: 703124496075433867
X-VR-SPAMSTATE: OK
X-VR-SPAMSCORE: 0
X-VR-SPAMCAUSE: gggruggvucftvghtrhhoucdtuddrgedvtddruddtgdekgecutefuodetggdotefrodftvfcurfhrohhfihhlvgemucfqggfjpdevjffgvefmvefgnecuuegrihhlohhuthemucehtddtnecunecujfgurhepggfgtgfuhffvfffksehtqhertddttdejnecuhfhrohhmpedfsfhuvghnthhinhcuuehouhhgvghtfdcuoeihphhsrghhseguvghvhigrrhgurdhorhhgqeenucggtffrrghtthgvrhhnpeeiteelteevveetfffgieeigeeugfelieelgeevjeelfeeggfefudekuefgleeiffenucffohhmrghinhepghhithhhuhgsrdgtohhmpdifhhgrmhgtlhhouhgurdgtohhmnecukfhppedtrddtrddtrddtpddvudefrddutddrudeijedrjeegnecuvehluhhsthgvrhfuihiivgeptdenucfrrghrrghmpehmohguvgepshhmthhpqdhouhhtpdhhvghlohepphhlrgihvghrudehjedrhhgrrdhovhhhrdhnvghtpdhinhgvtheptddrtddrtddrtddpmhgrihhlfhhrohhmpegrshhhphihseguvghvhigrrhgurdhorhhgpdhrtghpthhtoheplhhushhtrhgvqdguvghvvghlsehlihhsthhsrdhluhhsthhrvgdrohhrgh
Subject: [lustre-devel] [robinhood-v4] Help wanted
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

Hi everyone,

I'm looking for someone interested in contributing a lustre/robinhood-v4
connector.

The work involves converting Lustre changelog records into RobinHood
fsevents. [0] [1] [2]

I am willing to groom and maintain any code that the community will be
able to contribute, but I am not interested in doing the ground work
myself. I would be happy to guide and help anyone who steps up to the
task though.

I still expect LU-12574 [3] to be a blocker for any filesystem using
DNEv2, but besides that, the complexity of writing the converter itself
should be minimal.

Feel free to contact me directly if you want more information, or
respond on the mailing list.

Cheers,
Quentin

[0] https://github.com/cea-hpc/librobinhood/blob/main/doc/internals.rst#fsevent
[1] https://github.com/cea-hpc/librobinhood/blob/main/include/robinhood/fsevent.h
[2] https://github.com/cea-hpc/rbh-fsevents
[3] https://jira.whamcloud.com/browse/LU-12574

PS: for those who do not recognize this email address, I quit CEA a few
    months ago, you may have better known me as quentin.bouget@cea.fr
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
