Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 6D636D637D2
	for <lustre-devel@archiver.kernel.org>; Wed, 13 Nov 2024 23:57:06 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XpgDp5XH4z1wkm;
	Wed, 13 Nov 2024 15:56:58 -0800 (PST)
Received: from mail-pj1-f42.google.com (mail-pj1-f42.google.com
 [209.85.216.42])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XpgDn4jS9z1wfJ
 for <lustre-devel@lists.lustre.org>; Wed, 13 Nov 2024 15:56:57 -0800 (PST)
Received: by mail-pj1-f42.google.com with SMTP id
 98e67ed59e1d1-2e2bd0e2c4fso46501a91.3
 for <lustre-devel@lists.lustre.org>; Wed, 13 Nov 2024 15:56:57 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1731542216; x=1732147016; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=IH2iJvThfmeSx9ppIVJIEI7RCffVgi/M9gXGg/WI3zg=;
 b=CrGQxyY4d0uMA96e/ywsCdvr93+5K9z8TjdMPkF31dwlfzPz2DyAM4UJ4KuLUvdomF
 w8nKapswWFLJ9BUX/CWwxtdwdPqxYInEPTqPMafjU6nHAOJBYjFZB9L+/VlaNGGKQnJf
 BfzsHdchQZ4+eIQ1EXNAxrQI+gk3XiliDQCoIN73sBV232+TKoGdf7ZWenp4ogMstM3+
 4LCV59rh7uIpjL0Kasr47xcKisR/PjDRjBdaiSaAmkSw5I2F8eqqqhhYLzdF/LvUAw2B
 gBIpRtiJRE7Er/xFdVfBp00+K8uoOY43MCdyJKymmFcemZALyGfECW1WZpUmRmaidGKk
 fhdQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1731542216; x=1732147016;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=IH2iJvThfmeSx9ppIVJIEI7RCffVgi/M9gXGg/WI3zg=;
 b=GzkFdtqDW2xO/qTbrFWzJp5GCRXT2M7SpvWEHnbC/2J2svc0MD3zbKrv4aMTIugBez
 H4EASRLupsRowGIoCGn1u6SpuUsj+UNBh1lZYbdUZMcr6KXKcLZYemQfixBwyXdoMzEF
 WU0JhkOk2cJRLSXAzG3JxAhyIplG8ktIrte7lXXTN4TBV09qERGDh3icwYDBQD6C68jr
 OwViLUSQj4/Wi5b9xBKyhYaTjTAaxeB7IpXw+szfBEp9nPrhhkUJ75bnyl1kVGeQT72t
 n9wzKnDvf8m51tgzdLBUhbETRwtd0pWupoFga+bR9yBz4ZnytsOpcBhE3AxOCBJjbV2z
 MmsA==
X-Gm-Message-State: AOJu0YyuMa2vskUPKmD7n1XcwCF8ZYHXVOBY6Kx3Fb8dqxkFPmvPz8Hm
 P5bd8A64ag9ZYcttAr54zoLY3rjDefmNe0lw2KGy8LsF04zYVbVwYpUwtuA5FoeFbjYjHJMiM/W
 eu6fY9c6BwsDxrXfiyoPrzJGwh07S7YLFt+Y=
X-Google-Smtp-Source: AGHT+IFpHShYNazgUbzYsU+t/V9kCnTyS4ClZAHVujO61yo6f4IpIKJNVTQxiiSi+eAGh0S8VIHEA2VToyLC0VzCGaA=
X-Received: by 2002:a17:90b:4a49:b0:2e2:9038:4a48 with SMTP id
 98e67ed59e1d1-2e9f2d64552mr5313901a91.32.1731542216364; Wed, 13 Nov 2024
 15:56:56 -0800 (PST)
MIME-Version: 1.0
From: Ravi Theja Reddy <ravithejareddy99@gmail.com>
Date: Wed, 13 Nov 2024 15:56:45 -0800
Message-ID: <CAL=3WkTMXNgTkFQAOXp6z1TAkHPEJ8r=58Cjte3ORmVRJd1PZQ@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Using root squashing on lustre
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
Content-Type: multipart/mixed; boundary="===============7670882313587011845=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7670882313587011845==
Content-Type: multipart/alternative; boundary="000000000000b85d1b0626d4162c"

--000000000000b85d1b0626d4162c
Content-Type: text/plain; charset="UTF-8"

Hi,

I am looking to have rootsquashing feature on lustre. As part of it, I
noticed we have 2 potential ways of doing it.
1. Setting the root_squash params for all MDTs (Can be done using lctl
conf_param). We also have the nosuash_nids param too which we can set
to provide root access to desired clients.
2. Using  nodemap feature to enforce root squash and as part of it,
creating a trustedSystems node map_group for all the lustre server_nids
and set the admin and trusted properties. And later removing the admin and
trusted properties for default nodemap group and squash the UID and GIDs.

When checked on latest lustre manual, it recommends the nodemap way, Can
someone help understand what are the pros and cons of these 2 ways ?

Also have a question around nodemap, As part of node map feature, we
need to add all the lustre server_nids. what would be the
consequences/behaviour of FS if we do not add all
the lustre server_nids into trustedSystems group ?


Thanks,
Theja

--000000000000b85d1b0626d4162c
Content-Type: text/html; charset="UTF-8"

<div dir="ltr"><div><font face="arial, sans-serif">Hi,</font></div><div><pre style="color:rgb(0,0,0)"><font face="arial, sans-serif">I am looking to have rootsquashing feature on lustre. As part of it, I
noticed we have 2 potential ways of doing it.
1. Setting the root_squash params for all MDTs (Can be done using lctl conf_param). We also have the nosuash_nids param too which we can set to provide root access to desired clients.
2. Using  nodemap feature to enforce root squash and as part of it,
creating a trustedSystems node map_group for all the lustre server_nids
and set the admin and trusted properties. And later removing the admin and
trusted properties for default nodemap group and squash the UID and GIDs.

When checked on latest lustre manual, it recommends the nodemap way, Can
someone help understand what are the pros and cons of these 2 ways ?

Also have a question around nodemap, As part of node map feature, we need to add all the lustre server_nids. what would be the consequences/behaviour of FS if we do not add all
the lustre server_nids into trustedSystems group ?

</font></pre></div><div><font face="arial, sans-serif">Thanks,</font></div><div><font face="arial, sans-serif">Theja</font></div></div>

--000000000000b85d1b0626d4162c--

--===============7670882313587011845==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7670882313587011845==--
