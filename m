Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id F3715C3ABAA
	for <lustre-devel@archiver.kernel.org>; Fri,  2 May 2025 17:39:36 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4Zpypw0JWhz1xNq;
	Fri, 02 May 2025 10:39:36 -0700 (PDT)
Received: from mail-lj1-f169.google.com (mail-lj1-f169.google.com
 [209.85.208.169])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4Zpyps3plfz1whs
 for <lustre-devel@lists.lustre.org>; Fri, 02 May 2025 10:39:33 -0700 (PDT)
Received: by mail-lj1-f169.google.com with SMTP id
 38308e7fff4ca-30bfb6ab47cso19420651fa.3
 for <lustre-devel@lists.lustre.org>; Fri, 02 May 2025 10:39:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20230601; t=1746207570; x=1746812370; darn=lists.lustre.org;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=BpQtE8dNhBY/QBvex9Mj/uRZlMHmX3CjrezGTtIS7Jk=;
 b=herIDcMsxpPq4v/KPNInFjuN+7hrvJfRCOh33+fKGuG4ZAkA6w3CWHQutFSlC6U5gc
 vSWfIsO6my/r1MRMaY2mn+/EwEoyq4JTukKwIwlBUcvI8ePinpbTLDdOou1kmA1d36O6
 UnGC8sHRpNBF5I3ulyIZp4BNjOGI7krZW8RuPadw2jEwuEk7vs0Y81aXmhXzXrMlCGXj
 cxSnNutDDy9zSTWoe2WWDBlVCTVcNFew5PqquL4dn6hAPq3xPVptA04SBrEmn1lf+gz1
 jXI3FmqIslOAL/37P/grrFS6XgiBYkiF4fPFhQMSpwxy1RjoS06yPSZUqBRs8GSpwUAv
 bQJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20230601; t=1746207570; x=1746812370;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=BpQtE8dNhBY/QBvex9Mj/uRZlMHmX3CjrezGTtIS7Jk=;
 b=n1pr1cbuXO2VmZEI7Ofi9Y53wcxRKn5TNf33kxYPiGnv6QcGn3ZNwKhYayVMAUPZPC
 OiZdSi6GLLCG1hPMiLa22RcXQK/F68co/NJ+LItpiGztbYuis/JjyeGH3uSMg+K24bI4
 mUyRsfSZ9xzvoB+nNRu5V+Vr4FlIipE9y4qB+54BgMy9QYCiPFnkAjuDeszOuzPuaPZi
 4q4OXOaFZAuLlG3rKay4sQxZK/RsoyKG/WfCalOXTDBzx+POm3oNrHIigYV5YKOUs5z/
 ISTOWgPR+GCmjIk5xodNFOb2KqcXL0gBZ2+7dMvC+B8IqVmLR+XEiZLaBmyvK0TzDO1R
 LQQg==
X-Gm-Message-State: AOJu0Yyfe5Z+1cl9OQ1AsK1CJZ2wQFrw7kK1y1aibLUbS7e3+sJD8edI
 OolSTvIbJfJAKpHypbqHzTKlBxaXTpm/LSCA1BPgLxNaVetSYZazHt4RLZziZo3OSa8w/E6vwNg
 vpsV+Y3hmc4GJphcjVOnm0G0PgtyjsR0=
X-Gm-Gg: ASbGncvsaFUrAOmFqbxL0nk/4SfzyX0kqvVf6O61pWPY6pSJEBDekTZ8pdH3rOrnYbY
 9hY/O/U2QhDDVrayPqeXI2jT5bi5YuHTzqAQxqHqKeKv5G5NL4rx57dNOdkAOjjdh5es6V3U/sB
 jMvSRA/stW6Qf/Qal/zzY=
X-Google-Smtp-Source: AGHT+IErVUejUfSLJldzmBTTcSiHs5UA5IUAOBD8Z3k0jqjPZ5tRzfCMLcjfsGqHztDJR3UWM2tTPvfw4lfra3ll/uU=
X-Received: by 2002:a05:651c:1617:b0:30a:4428:dea9 with SMTP id
 38308e7fff4ca-320c57f666emr12981131fa.30.1746207570115; Fri, 02 May 2025
 10:39:30 -0700 (PDT)
MIME-Version: 1.0
From: Praveen Solanki <praveen.solanki@gmail.com>
Date: Fri, 2 May 2025 13:39:18 -0400
X-Gm-Features: ATxdqUHmEJGq4KC0iLgmmOq8Qo5VZINWWDigS9LB5y2Yj88GpCzJnZbTXjzYVmc
Message-ID: <CAJTK79B36DFi-t5Bh+BAQYhdSobC=Rg5fMyN9t_WwG-jhFdxRQ@mail.gmail.com>
To: lustre-devel@lists.lustre.org
Subject: [lustre-devel] Requesting input on LU-18972
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
Content-Type: multipart/mixed; boundary="===============8400643832151724996=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============8400643832151724996==
Content-Type: multipart/alternative; boundary="000000000000ebc04706342aa10e"

--000000000000ebc04706342aa10e
Content-Type: text/plain; charset="UTF-8"

Hello community,

I created

https://jira.whamcloud.com/browse/LU-18972

This is a ticket for a small change I wish to make that would help users of
lustreapi to list MDT devices.

Appreciate your guidance in this regard if this is something that will make
sense to do.
Also this would be my first change so any additional guidance is
appreciated.

Regards
- Praveen

--000000000000ebc04706342aa10e
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div>Hello community,</div><div><br></div><div>I created=
=C2=A0</div><div><br></div><div><a href=3D"https://jira.whamcloud.com/brows=
e/LU-18972">https://jira.whamcloud.com/browse/LU-18972</a></div><div><br></=
div><div>This is a ticket for a small change I wish to make that would help=
 users of lustreapi to list MDT devices. <br></div><div><br></div><div>Appr=
eciate your guidance in this regard if this is something that will make sen=
se to do.</div><div>Also this would be my first change so any additional gu=
idance is appreciated.</div><div><br></div><div>Regards</div><div>- Praveen=
</div></div>

--000000000000ebc04706342aa10e--

--===============8400643832151724996==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============8400643832151724996==--
