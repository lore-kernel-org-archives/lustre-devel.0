Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id D50CDC46CD2
	for <lustre-devel@archiver.kernel.org>; Mon, 22 Jan 2024 21:24:02 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4TJjhv4zCVz22Rg;
	Mon, 22 Jan 2024 13:17:03 -0800 (PST)
Received: from mail-yb1-f175.google.com (mail-yb1-f175.google.com
 [209.85.219.175])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4TJjhQ5JJQz22RN
 for <lustre-devel@lists.lustre.org>; Mon, 22 Jan 2024 13:16:38 -0800 (PST)
Received: by mail-yb1-f175.google.com with SMTP id
 3f1490d57ef6-dc25e12cc63so3114786276.0
 for <lustre-devel@lists.lustre.org>; Mon, 22 Jan 2024 13:16:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=aeoncomputing-com.20230601.gappssmtp.com; s=20230601; t=1705958165;
 x=1706562965; darn=lists.lustre.org; 
 h=to:subject:message-id:date:from:in-reply-to:references:mime-version
 :from:to:cc:subject:date:message-id:reply-to;
 bh=lnfKoWloR+awWap23iIpcyYVUXmafqFVr4yF9z7nxVw=;
 b=sVntZL+NRjgxRZNjLRPVthNvdrenu+VP27e5Z1TZg5ct62sVTCshnIylYI73VUMCvP
 CbrvR0mLMiMzT2DfevmW4KSbhuQvn//smrbJJxTKn3mRSuyHuwgP2dGNYDOiCoEzlvBa
 v+75dwATaBhpOoiTTC66G77kAhi0OXQ266n6IA16Jz0Iz+eaY7UugbrgUxdhUKZsnbYU
 Clsmcw8kQnaFK9SimwLHuTTofw/VZTjPbXVc9hHkxr+8C32MfeUg3bTNKzYLjDCPp9Th
 5dtGuZLzflTIZmj/sGH7m85Qk1QQVH4YGiymUkXNX6Vrx7YKSpEI/ouXIJ3YAsU/N5tv
 27nA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1705958165; x=1706562965;
 h=to:subject:message-id:date:from:in-reply-to:references:mime-version
 :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
 bh=lnfKoWloR+awWap23iIpcyYVUXmafqFVr4yF9z7nxVw=;
 b=G2T1kAw05sboBNc7RBd6SPwmESeOIFuESRWvkk6A1AbvZxZFORx9D60lqNw+rFIahy
 mLvt2Tel6j2mpnUgv1OsMKeVUOFW+huZHvPgzdXh07KK4CBo5To8+bLqsNdPFWBNWRvp
 ruSYwC/KLMR8DZlXLFJNk0Jg6+UUpN8dvlCXUe/PSyOGmmsoaXGybsv5pRYoMEjnj+c8
 A5C4opJhNKLMg8xDx9/7Ar0VRWk/HeXlVl+791Vde5EN9nMy30N0s3Bzw9Zs45OBiahb
 ht1Ue9nLDoiXYou7qK8R4HFCKHGM+vcdktsqUTkZuanBHe2dDNW1CQMNZ7z36PF3oy/p
 dbpA==
X-Gm-Message-State: AOJu0YxzS7dVROfe1vW36u0oLS1mkrAAY7mFQKygPtAh+tx8qxlAbzF0
 9kjoiq2WZakt7HJ9NxpomyZt4HNhgkzcsbgv97dY7pz4tdwR880wP9el0TxwFEybQyyOSgWM10A
 mbcm+3pLtEE47GHqz0QvSMXrIC0Oy8yfH4NZpshN2hwO/DQi+
X-Google-Smtp-Source: AGHT+IE6IlKdL10hqqltvUf9HnQvr5y3n3uPKj43X32Pwjac5Jlo+MXAiRnVwHa35k/jzAGOrlrtzQbNKRahS4CRZjA=
X-Received: by 2002:a25:a290:0:b0:dbd:b153:a1ee with SMTP id
 c16-20020a25a290000000b00dbdb153a1eemr3436896ybi.10.1705958165155; Mon, 22
 Jan 2024 13:16:05 -0800 (PST)
MIME-Version: 1.0
References: <CAFCYAsfNnaLzKZrOTLLOc0S3077reuEWjs0ytJYNHm4+-5R4Sw@mail.gmail.com>
 <1817A78F-4EDD-4832-9859-AEA980B32A25@ddn.com>
In-Reply-To: <1817A78F-4EDD-4832-9859-AEA980B32A25@ddn.com>
From: Jeff Johnson <jeff.johnson@aeoncomputing.com>
Date: Mon, 22 Jan 2024 13:15:53 -0800
Message-ID: <CAFCYAscZ-P60oXOhZjGyyK1n7vBTgOsgyECs+cYrOtbP=Y1zdw@mail.gmail.com>
To: "lustre-devel@lists.lustre.org" <lustre-devel@lists.lustre.org>
Subject: Re: [lustre-devel] Cannot find documentation or comment blocks
 specifically defining lnet metrics
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
Content-Type: multipart/mixed; boundary="===============7307635816378266217=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7307635816378266217==
Content-Type: multipart/alternative; boundary="0000000000006fb4ca060f8f56b3"

--0000000000006fb4ca060f8f56b3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Thanks! I dug around there before and didn=E2=80=99t find the info. I=E2=80=
=99ll look
again. If anyone else on the list can opine, please do.

=E2=80=94Jeff

On Mon, Jan 22, 2024 at 12:39 Andreas Dilger <adilger@whamcloud.com> wrote:

> Did you try wiki.whamcloud.com?  Amir used to like creating pages for
> LNet there, so there might be something.
>

--0000000000006fb4ca060f8f56b3
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"auto">Thanks! I dug around there before and didn=E2=80=99t find=
 the info. I=E2=80=99ll look again. If anyone else on the list can opine, p=
lease do.=C2=A0</div><div dir=3D"auto"><br></div><div dir=3D"auto">=E2=80=
=94Jeff</div><div dir=3D"auto"><br><div class=3D"gmail_quote" dir=3D"auto">=
<div dir=3D"ltr" class=3D"gmail_attr">On Mon, Jan 22, 2024 at 12:39 Andreas=
 Dilger &lt;<a href=3D"mailto:adilger@whamcloud.com">adilger@whamcloud.com<=
/a>&gt; wrote:<br></div><blockquote class=3D"gmail_quote" style=3D"margin:0=
px 0px 0px 0.8ex;border-left-width:1px;border-left-style:solid;padding-left=
:1ex;border-left-color:rgb(204,204,204)">



<div style=3D"line-break:after-white-space" dir=3D"auto">
Did you try <a href=3D"http://wiki.whamcloud.com" target=3D"_blank">wiki.wh=
amcloud.com</a>?=C2=A0 Amir used to like creating pages for LNet there, so =
there might be something.</div></blockquote></div></div>

--0000000000006fb4ca060f8f56b3--

--===============7307635816378266217==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7307635816378266217==--
