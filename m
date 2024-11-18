Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id B214FD43FE6
	for <lustre-devel@archiver.kernel.org>; Mon, 18 Nov 2024 08:12:03 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4XsL2202ynz1xPS;
	Mon, 18 Nov 2024 00:11:53 -0800 (PST)
Received: from mail-pg1-f176.google.com (mail-pg1-f176.google.com
 [209.85.215.176])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4XsL1y4PLnz1xFH
 for <lustre-devel@lists.lustre.org>; Mon, 18 Nov 2024 00:11:50 -0800 (PST)
Received: by mail-pg1-f176.google.com with SMTP id
 41be03b00d2f7-7edb6879196so2777454a12.3
 for <lustre-devel@lists.lustre.org>; Mon, 18 Nov 2024 00:11:50 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1731917510; x=1732522310; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=leFHWvkGTwEcIaepSH8v2+25Lb7IbW/ied0L9WPf0qE=;
 b=h6GC3Zj3L1y9AI12KS0M82RDR80vQ5kul7dF4ZYWcmz6w8PYgOwHJnQoEQ+3Oi+LYf
 tcVnpjE80vR12j5qX8fOGwVgGCWZUJK3CqUuG7kk3HZyRptRwGKno3Ky42TjtSO747GR
 0NDDFN76GneEzQUAUcIYgukY4nTVEd+p6G9iv8xHrAOa42ozp9vxhWFn7eBaEnyajQ2T
 VJi32zyn18jvntW/VsytnAFxdyiHaKq+pf9SiMlZfxpyc6t1O8R73UX4mbvR+jWF4YPV
 pQTFiSKEvII8pv8XA6yTuwb1XKdiJza2Cj4Wi3GjMpDpzhR4xrz7WlmOg4tiMHR/pWV2
 DdVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1731917510; x=1732522310;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=leFHWvkGTwEcIaepSH8v2+25Lb7IbW/ied0L9WPf0qE=;
 b=QPcJtxPkGf6THxq20MU0umgNRL6GP/y6O7KcLWWE1iWKyE35FQKQ0SHH3KngTjmo7w
 YX3Q6hFDalOzXBQQ2R+kp8fax6FmTd1T7oEuZIJ4x8rmVwDA5n5uMNLM19A1EShiczao
 xpLy0boODvYMWArIrWwYHsurkchw2UKa6wpSehvMEFnw4VBpDo/Fy5p6jdJ4IlQs2S/B
 mMHYMQSB1csrVfCO5IlrlQReUKf4YO5PeA8aio5KHJEH/2ekdrLuTN1SWiz4+co4gb3Y
 PrVgRsEUhqoKGMur+bjs4dg1em018eDGlyUjYYGur98ues0T6IYDvHLwcYodnEVbYP//
 NCcA==
X-Gm-Message-State: AOJu0YyHI0uDAHp0b5zVxxmZQhVnybuEvgmOlyeCRyDINYNKcZB6r8/p
 CaZy+JjytOXdpZG1snsdBH4ROT56ZLHf1kXoE3WBgcoZ/tiaLFYy7fEmVL/zCxVISh9BKdARrDA
 OMwkKKLklpOhTeFTnL/AMOD+B6q378LSA
X-Google-Smtp-Source: AGHT+IGKPMp1vWGAx12qRn2bb2v/WKSuka4PwSPMprSBf8i66JjdMnLQ1KWilN87yGQJkj1W/JH629pyDv7M+vl1IPA=
X-Received: by 2002:a17:90b:1dc2:b0:2ea:3a13:4916 with SMTP id
 98e67ed59e1d1-2ea3a134bb6mr8898414a91.6.1731917509549; Mon, 18 Nov 2024
 00:11:49 -0800 (PST)
MIME-Version: 1.0
From: keguang xu <squalfof@gmail.com>
Date: Mon, 18 Nov 2024 16:11:38 +0800
Message-ID: <CAF83deS+MC_ZKr9vXix_Js63ZyJ2KkXsSwLg5FeBs-+NziYf3Q@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] HELP: difference between fallocate and truncate
 implementation
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
Content-Type: multipart/mixed; boundary="===============1304818495506167088=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============1304818495506167088==
Content-Type: multipart/alternative; boundary="000000000000efe64806272b771a"

--000000000000efe64806272b771a
Content-Type: text/plain; charset="UTF-8"

Hi Lustre devs,

I came across the code and noticed an implementation difference between
fallocate and truncate/punch operations under the lustre/osd-ldiskfs/.
While *osd_fallocate*() is handled in the Lustre OSD layer, *osd_punch*()
remains in the ldiskfs layer, both of which may relate to multiple
transactions as their comments suggested.
- from LU-13765 <https://review.whamcloud.com/c/fs/lustre-release/+/39342>,
it explains why move fallocate() from ldiskfs upto OSD layer (due to
unpredictable credits ahead), however truncate() resides in ldiskfs layer
instead of moving upto OSD layer?
- LU-10048 <https://review.whamcloud.com/c/fs/lustre-release/+/27488>
claims to "avoids restarting truncate transaction handles in main
transaction", while in osd_fallocate_preallocate() it seems there's no such
concern? Besides, why should we avoid restarting?

Correct me if I misunderstood the code above...Thank you for your input.

Best Regards,
kg.xu

--000000000000efe64806272b771a
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi Lustre devs,<br><br>I came across the code and noticed =
an implementation difference between fallocate and truncate/punch operation=
s under the lustre/osd-ldiskfs/. While <b>osd_fallocate</b>() is handled in=
 the Lustre OSD layer, <b>osd_punch</b>() remains in the ldiskfs layer, bot=
h of which may relate=C2=A0to multiple transactions as their comments sugge=
sted.<br>- from <a href=3D"https://review.whamcloud.com/c/fs/lustre-release=
/+/39342">LU-13765</a>, it explains why move fallocate() from ldiskfs upto =
OSD layer (due to unpredictable credits ahead), however truncate() resides =
in ldiskfs layer instead of moving upto OSD layer?<br>- <a href=3D"https://=
review.whamcloud.com/c/fs/lustre-release/+/27488">LU-10048</a> claims to &q=
uot;avoids restarting truncate transaction handles in main transaction&quot=
;, while in osd_fallocate_preallocate() it seems there&#39;s no such concer=
n? Besides, why should we avoid restarting?<br><br>Correct me if I misunder=
stood the code above...Thank you for your input.<br><br>Best Regards,<br>kg=
.xu</div>

--000000000000efe64806272b771a--

--===============1304818495506167088==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============1304818495506167088==--
