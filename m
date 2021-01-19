Return-Path: <SRS0=SMzG=GW=lists.lustre.org=lustre-devel-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: **
X-Spam-Status: No, score=2.5 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,HTML_MESSAGE,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB3DAC433E0
	for <lustre-devel@archiver.kernel.org>; Tue, 19 Jan 2021 19:40:58 +0000 (UTC)
Received: from pdx1-mailman02.dreamhost.com (pdx1-mailman02.dreamhost.com [64.90.62.194])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 6252923105
	for <lustre-devel@archiver.kernel.org>; Tue, 19 Jan 2021 19:40:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6252923105
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=lustre-devel-bounces@lists.lustre.org
Received: from pdx1-mailman02.dreamhost.com (localhost [IPv6:::1])
	by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 9DB8121FC01;
	Tue, 19 Jan 2021 11:40:57 -0800 (PST)
Received: from mail-wm1-f48.google.com (mail-wm1-f48.google.com
 [209.85.128.48])
 by pdx1-mailman02.dreamhost.com (Postfix) with ESMTP id 2CBCD21FBB8
 for <lustre-devel@lists.lustre.org>; Tue, 19 Jan 2021 11:40:56 -0800 (PST)
Received: by mail-wm1-f48.google.com with SMTP id v184so816499wma.1
 for <lustre-devel@lists.lustre.org>; Tue, 19 Jan 2021 11:40:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:from:date:message-id:subject:to;
 bh=2levCexlLb2ez732rNV4VsGngEdmvpDVkC1+pUEoxcs=;
 b=SzrHRMakUiPNIy46ODH7KzBboyyOT/AbCBa1bgCNgbiYgmGeDtGjqSr0StNV00UIoR
 6TfMwrJhcAqppRL/Fq4N1kC0jYWF1sRmwJmQ0KPKJf/voKuaVGvgnFRYXHQb/T75DYbr
 S9+82ryQWjHa02M3Q4QcZV7wd6bdCF6xPVw7Vtb2bIAb9fML9rWLIrieQq5tsMfAi0af
 6qAAoWNYhpFjeNCU7IPUQ/86VyL3UsVLL5WWrIspChIrE1kF0UaMgrAEjGDocF+UFFla
 LqbSDM3bhTk9fwFq4BoKpV2eSJog20hwFzbcZRD9BAcKxS3/MMCzIt3tZH/HK+WAHpQ+
 +KjQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
 bh=2levCexlLb2ez732rNV4VsGngEdmvpDVkC1+pUEoxcs=;
 b=FkyYvkZs5nTaDBEv0Vis9p75EfrxAbedndhziGm+d2kQAcgZqdZK1ZpJb8+kckRZ02
 rqA/5eZaImCqBRP3LTeFsQR56/06ScBPKufeX+7/CjjvD+TXOYvYY51kWVWsSxzGrtDo
 XL2YjYfCYwveZTR2jVgfq9VXk/uoENc4tM/AyL1QEkzbrtNWzDazp9xIkovtV0WS+L2o
 a1KGtlwVai7yv6vwxslMh7k3DevxgClL3dekskkOMsyyMEpwNDOxHWBC4UQf1cOiGYpN
 ELjDALPrexTk6PnqswidUQdT0Fk52hrAedZpohKlFwHb177M9r3x+nhN5GJDC7irUPfA
 0CVg==
X-Gm-Message-State: AOAM533+vZAUSTxU++Nn3E9fJuxXGZeoBmZK7n2DPTeaNkicUObsr9F1
 PzIsF4tP7sKTfqAd/B/NXBVgw1Rh8QylE09MqCj0eCvMdNg=
X-Google-Smtp-Source: ABdhPJy8UZhQh+mUCWps5++1VEXU6Pw4YgyLL+ED+vrwADgrd5yL0HktFHY9VmvgfeEF6XbOlmr4BBBdX+bOvaonxww=
X-Received: by 2002:a1c:ba83:: with SMTP id k125mr1060139wmf.5.1611085254264; 
 Tue, 19 Jan 2021 11:40:54 -0800 (PST)
MIME-Version: 1.0
From: Sudheendra Sampath <sudheendra.sampath@gmail.com>
Date: Tue, 19 Jan 2021 11:40:18 -0800
Message-ID: <CABnqofyTN6Cr8JaMgeoke5TWG9j0JL_vMq03YPd8sYuRHXfqcw@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Getting client UUID from transaction code
 (osd_trans_create) - osd-zfs
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
Content-Type: multipart/mixed; boundary="===============3347216266836981785=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============3347216266836981785==
Content-Type: multipart/alternative; boundary="000000000000488b6505b94604ac"

--000000000000488b6505b94604ac
Content-Type: text/plain; charset="UTF-8"

Hi,

When I have multiple 'remote' clients writing data, I am trying to find a
way to recognize which client data I am writing to the underlying storage.

Appreciate if anyone in this list can point me in the right direction to
access remote client UUID.

Thanks,

Sudheendra Sampath

--000000000000488b6505b94604ac
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Hi,<div><br></div><div>When I have multiple &#39;remote&#3=
9; clients writing data, I am trying to find a way to recognize which clien=
t data I am writing to the underlying storage.</div><div><br></div><div><di=
v>Appreciate if anyone in this list can point=C2=A0me in the right directio=
n to access remote client UUID.</div><div><br></div><div>Thanks,</div><div =
dir=3D"ltr" class=3D"gmail_signature" data-smartmail=3D"gmail_signature"><b=
r>Sudheendra Sampath</div></div></div>

--000000000000488b6505b94604ac--

--===============3347216266836981785==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============3347216266836981785==--
