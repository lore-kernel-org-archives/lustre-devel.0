Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 376BBC47DDB
	for <lustre-devel@archiver.kernel.org>; Fri, 26 Jan 2024 19:57:42 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4TM7lV3sYNz1y7y;
	Fri, 26 Jan 2024 11:57:42 -0800 (PST)
Received: from mail-yw1-f175.google.com (mail-yw1-f175.google.com
 [209.85.128.175])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4TM7lS5dwLz1y5t
 for <lustre-devel@lists.lustre.org>; Fri, 26 Jan 2024 11:57:40 -0800 (PST)
Received: by mail-yw1-f175.google.com with SMTP id
 00721157ae682-602cab8d7c9so9486277b3.0
 for <lustre-devel@lists.lustre.org>; Fri, 26 Jan 2024 11:57:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=charlotte.edu; s=google; t=1706299059; x=1706903859; darn=lists.lustre.org; 
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=pOOMLLoex7u5NF18JaR36Jk83t1LZeeBDGyxgpgG4PA=;
 b=ULOlgmFclXBi2MVo6ySgLfFGSHyxfVOxvj05uWiVx5BTrgExo7g2eLSS9wejLc1mac
 CFPOKpAEg20x9QNSlaIUP6K3Lhavgd3cPmV6ubcJEzV81D9rd2hGf7NTYEbC3Hsie2Mq
 lUwBBT7SKVtopqkcAxLtkIqHRWnZI3RHw3vR/HhHs/sYiqZv1Yc19A69ixMCL/fZCiRD
 VQYG0bLq7nwnBaEu7lkJuzMupxx/yBEgL8995rMtzC0ML1oR8KtoJEG3lWW+JfOtc+Ig
 7Y85FYxHyTSLh3EA18MShknOZMtMw+lCHkWrlz17kfAEi+OztbPh5arXa1qxlRZB1HXU
 GwjA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1706299059; x=1706903859;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=pOOMLLoex7u5NF18JaR36Jk83t1LZeeBDGyxgpgG4PA=;
 b=P0PZAJkCu4ed+Uh6QII9j/nAVx4jROl+paS3tZYWDpFxFl1Xy68SRroE/jU2BHdDPS
 DmLNUeL4irMkaL48jgxLgqkHm9D881uuPdbOQGZH3P1tDBgmWwki4PowfhTUQWToFOsT
 gPPOhk5tlgBNpMAeBKaU/DC9LUjQNU5ZS1NHXjetsh2k1/Bc79LhieYKO7EpffrjSDMM
 u50+EMx78MkTLbq08VGikpccBnUTvRyBCSSbtsNLHHnW1bCluhVlTUuBtgm0kjAGfiYh
 pKXKNio4mbeDJq51Hvl+Jsw8LT/+dZQmsmqdV17fLbMA4gX7q4SN3kR6BG73BB4NYpUI
 1bUw==
X-Gm-Message-State: AOJu0YyBBQBg5BYFBraQWOB14+U7jYj3MblD2/nbmUFSDy9SNKW9ZDOz
 3G0apEcxmu2mCQUz8htKvW7Hlb3Cwv58hbdFd0UvjF+Xrkw0dUhkJf777uLC0WSr0Fp6mTLM5n2
 z97qOvyFC09O5vAgtrsMXN/xGmW1jFs9dSXBaeVxMuxiEmKL9SIUveQ==
X-Google-Smtp-Source: AGHT+IFbxLqYxzJ2mDTb0EaTW7NbfG1T7Saeew/Qov/SGAms2D63g5LZWwdJYtsuRUOvzeu/V3YIDkUuczjR7VR6aHQ=
X-Received: by 2002:a81:b187:0:b0:602:acba:ece1 with SMTP id
 p129-20020a81b187000000b00602acbaece1mr368409ywh.15.1706299059380; Fri, 26
 Jan 2024 11:57:39 -0800 (PST)
MIME-Version: 1.0
Date: Fri, 26 Jan 2024 14:57:28 -0500
Message-ID: <CACyzrcQosBre=vRYDN+VeB=o=9bB-mJGT=NrQBhJi_59Eqe7jw@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Direct Modification of Lustre Metadata on Disk
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
From: Saisha Kamat via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: Saisha Kamat <skamat1@charlotte.edu>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

Hello,

I am a Ph.D. student at UNC-Charlotte, focusing on research related to
the Lustre File System. As part of my project, I am investigating
scenarios involving the direct modification of xattr metadata on the
Lustre disk, without unmounting the Lustre servers.

To achieve this, I have attempted to open the MDS (Metadata Server)
disk partition as a file descriptor, locate the target file and its
xattr, and write a faulty value. However, I have encountered an
unexpected issue where my changes appear to be saved to memory and are
not being synchronized with the disk.
After completing the write operation, when I read the same xattr
again, it reflects the corrupted value. Strangely, when using the
"getfattr" command, the original, correct value is displayed. This
discrepancy has raised doubts about whether Lustre permits direct
modifications to its metadata on the disk.
Furthermore, I observed that even after unmounting and remounting the
Lustre file system, the xattr continues to display the corrupted value
upon reading, whereas "getfattr" still returns the original, correct
value.

Please help me understand whether Lustre allows direct modifications
to its metadata on the disk and if there are any inherent limitations
or considerations that I should be aware of.
Additionally, any recommendations or alternative approaches for
simulating faulty conditions for testing purposes would be highly
valuable to my research.

Thanks and Regards,
Saisha
_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org
