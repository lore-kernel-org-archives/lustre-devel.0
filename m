Return-Path: <SRS0=mxas=GX=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65449C433E0
	for <lustre-devel@archiver.kernel.org>; Wed, 20 Jan 2021 08:53:19 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 01C4322C9E
	for <lustre-devel@archiver.kernel.org>; Wed, 20 Jan 2021 08:53:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01C4322C9E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 0C39021F76D;
	Wed, 20 Jan 2021 00:53:18 -0800 (PST)
Received: from mail-lj1-f175.google.com (mail-lj1-f175.google.com
 [209.85.208.175])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 03BA421F753
 for <lustre-devel@lists.lustre.org>; Wed, 20 Jan 2021 00:53:16 -0800 (PST)
Received: by mail-lj1-f175.google.com with SMTP id e7so25151486ljg.10
 for <lustre-devel@lists.lustre.org>; Wed, 20 Jan 2021 00:53:15 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:from:date:message-id:subject:to;
 bh=8XspzKd613IXhqaH2DkkFEnB2whF0KhAeoL97uPNWtY=;
 b=P3tOLNGeF2Y3PoWU/ZEiSa66IfBfOIrfYMqJUMxpQB6nyOM32JLLWr++df2/BJza90
 1woUWtevP17Py6+XFipfhEkT79UAUDWVeCUoHcCpDo1C9MT54THR9c+At2DLl3urtCDf
 sl9Z8i0g3gqUVOhARVEA1qNYIUldhCVMTt2brpBWw8YecPdEEnkZxa8snn9WH1R/3Kkn
 usBiACY9XXN5g1+Xe/SMw9eMpiRkQ8gXTPuvpdJcJxMEdmCv2D5C4SlQ8N2UwusfR9T5
 ZBOwQ1d4MnR83mCSeGm9+95vExsJDAAAwwcROi2l+VUdd0jWnkqOW2X5pWE05lGd3pc4
 3yYQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
 bh=8XspzKd613IXhqaH2DkkFEnB2whF0KhAeoL97uPNWtY=;
 b=Eu8GR2OHeJFHhhtq/KFJ+IgAJ85/tJnY+qKqnF8zGz+yKbbuIaBidLrNs19Yn7g9Zz
 MbsyGNoGbW9gLmEEgB/3LQ1GpOBNosrGTTY/Cafg3JjL5NcZTeSYLMP4D09C3TOnuLnt
 ElPfajXFWrBoZyu+15YZErw5PVyLI1qjxGHdSBw1vSSJthuljt9e0+GtEGhVM3uO0ksx
 dCP0HwxRkhzQAxwc2rDP7C31M266h2GtYS35r/Bm8tk/FzYEnFGi+jjJ8MMIJ7Nn/T7s
 g137jf4ag0dazT4n53NrXeCd1lylhUVFsVA5jF/ubxJmnzSeWYICttzJDVkGTgluhOL0
 YduA==
X-Gm-Message-State: AOAM531mrBKLK4BPHq3swssu5r3bO+fb5JKawDWTwnUKyb6G8ZnV91Vw
 E57v8+I6ZaOLWRayUD2ALPkXMf2hYoWcOE5Dty6Hf7EB
X-Google-Smtp-Source: ABdhPJxIJPinw1hNFjHQQaa00lxYYanfWhNaxmCU/dsuefBjquBeXn3MxPsXoBjAtbfEJLdXbEMehw79o74YQNbr0iI=
X-Received: by 2002:a2e:86d2:: with SMTP id n18mr2575462ljj.398.1611132794012; 
 Wed, 20 Jan 2021 00:53:14 -0800 (PST)
MIME-Version: 1.0
From: pankaj sharma <vashist.pankaj@gmail.com>
Date: Wed, 20 Jan 2021 14:23:03 +0530
Message-ID: <CAN9a52DQnLrH7yd+mxjVtc2AmTvydpM_uzVZXqzErCha+91vHg@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Magnum I/O GPU direct
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
Content-Type: multipart/mixed; boundary="===============4281050508587116980=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============4281050508587116980==
Content-Type: multipart/alternative; boundary="000000000000df85a205b9511548"

--000000000000df85a205b9511548
Content-Type: text/plain; charset="UTF-8"

Hi,

I want to know is Magnum I/O GPU direct support is available in Lustre.

Regards,
Pankaj Sharma

--000000000000df85a205b9511548
Content-Type: text/html; charset="UTF-8"

<div dir="ltr">Hi,<div><br></div><div>I want to know is Magnum I/O GPU direct support is available in Lustre.</div><div><br></div><div>Regards,</div><div>Pankaj Sharma</div></div>

--000000000000df85a205b9511548--

--===============4281050508587116980==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============4281050508587116980==--
