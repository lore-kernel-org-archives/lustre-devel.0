Return-Path: <SRS0=rh8B=F2=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A394CC433DB
	for <lustre-devel@archiver.kernel.org>; Tue, 22 Dec 2020 20:26:23 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 5E32C22AAE
	for <lustre-devel@archiver.kernel.org>; Tue, 22 Dec 2020 20:26:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E32C22AAE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id AA82730B2D7;
	Tue, 22 Dec 2020 12:26:22 -0800 (PST)
Received: from mail-wm1-f46.google.com (mail-wm1-f46.google.com
 [209.85.128.46])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 524A021F6BC
 for <lustre-devel@lists.lustre.org>; Tue, 22 Dec 2020 12:26:21 -0800 (PST)
Received: by mail-wm1-f46.google.com with SMTP id 3so3499286wmg.4
 for <lustre-devel@lists.lustre.org>; Tue, 22 Dec 2020 12:26:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:from:date:message-id:subject:to;
 bh=PTQXynz62lswluLo77zZxPgA9nje3yxNe6XIzABNOpI=;
 b=SggiKpdjA+TcDpcKkf1YBHjXzTVCmoAWexEIWa/O4V+2/d0J2PV4R1UQvXaHmrzrGk
 wEVPbrbpqDewUjnLKi4SKXMagMc4zPD3gogAAyF4rimJWCG9VsKQBK4Vz9KVc6T3rj4N
 fC5gshan7Y0dFthn124AO8pcx6AAJ6CteYpXORIn/oQ9mxCRT/3Zr415MGzWiiQgJ9bh
 023heeu4/AcaCB8xbV+txxhgWBcxDby64BthnsryTHgk/x06SKOZYz0E5ybRd1pBQ2j4
 qeIMjZHgqsYj5Sn/NaYDFpfGddCApx/xpIGRIBqdjYb4v1VjngaBaf0CLjxmGhgp9ZLR
 9DDw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
 bh=PTQXynz62lswluLo77zZxPgA9nje3yxNe6XIzABNOpI=;
 b=WRIvC3fUsYgCWU3lT5/RSPAR7jH2VU5CTnv0kzXnRmA+rca6HRSPzWQ1Z6v5aTzqQf
 rUiW68SkokcQw+bavnXBwykbJmhCgNB1Gb+Qv708suMB/BPNQGA5FVhjy3J7a3Lme8tw
 Cc8I710i4SJGI0Qajdp20YKaro+jzCpjmLfhBu+EHA3eicGmuOf78exaInnslCSdaiBH
 J/k5Y/+jraILQJaIR96XnAPc8XOtnNU/ZXQjnPBxUc7ZuUkyil+tvsqN5FKtTxYf66SQ
 ayN824ulouht4SgIDyxpY1+2nEM/YU0zc5bZ7rk+jXkffhmV3C2czWIN8uagVOosRlIv
 ukOA==
X-Gm-Message-State: AOAM530zNbHrGlzKZi9FnuzlBYSa7m9pwZAXrlCDK6d5jyqPPyj+O6k/
 +2M568YMIk/HfV/f3s7Ce07aKiwvY4XQ8i3FrgjcXu4CYKgSSA==
X-Google-Smtp-Source: ABdhPJyjb7FBWMaxSbNH4cnYjfU+DBSorNXYkAn7OR9ZVNHUL2HxD/mkETbeDwHhmStfofE8dz9T9my74adrvTP+ebc=
X-Received: by 2002:a7b:cc90:: with SMTP id p16mr22833576wma.105.1608668779473; 
 Tue, 22 Dec 2020 12:26:19 -0800 (PST)
MIME-Version: 1.0
From: Sudheendra Sampath <sudheendra.sampath@gmail.com>
Date: Tue, 22 Dec 2020 12:25:42 -0800
Message-ID: <CABnqofyiOSkBVO4q1BfpMtN0AR3EO2gEsHruYdwYe+csEQShzw@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] mdc_resource_inode_free()
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
Content-Type: multipart/mixed; boundary="===============0989012760548868570=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============0989012760548868570==
Content-Type: multipart/alternative; boundary="000000000000296fc805b71363ec"

--000000000000296fc805b71363ec
Content-Type: text/plain; charset="UTF-8"

Hi,

I was trying to understand more about LDLM, specifically Lock Value Block
(LVB's) and stumbled upon the following code block :

static int mdc_resource_inode_free(struct ldlm_resource *res)
{
        if (res->lr_lvb_inode)
                res->lr_lvb_inode = NULL;

        return 0;
}

Shouldn't the pointer (lr_lvb_inode) be freed before assigning it to NULL
?

Just curious to know.
-- 
Regards

Sudheendra Sampath

--000000000000296fc805b71363ec
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,<div><br></div><div>I was trying to understand more abo=
ut LDLM, specifically Lock Value Block (LVB&#39;s) and stumbled upon the fo=
llowing code block :</div><div><br></div><div>static int mdc_resource_inode=
_free(struct ldlm_resource *res)<br>{<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 if (re=
s-&gt;lr_lvb_inode)<br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 res-&gt;lr_lvb_inode =3D NULL;<br><br>=C2=A0 =C2=A0 =C2=A0 =C2=A0 retur=
n 0;<br>}<br><div><br></div><div>Shouldn&#39;t the pointer (lr_lvb_inode) b=
e freed before assigning it to NULL ?=C2=A0=C2=A0</div><div><br></div><div>=
Just curious to know.</div>-- <br><div dir=3D"ltr" class=3D"gmail_signature=
" data-smartmail=3D"gmail_signature">Regards<br><br>Sudheendra Sampath</div=
></div></div>

--000000000000296fc805b71363ec--

--===============0989012760548868570==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============0989012760548868570==--
