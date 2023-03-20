Return-Path: <lustre-devel-bounces@lists.lustre.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from pdx1-mailman-customer002.dreamhost.com (listserver-buz.dreamhost.com [69.163.136.29])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.lore.kernel.org (Postfix) with ESMTPS id 286C5C6FD1D
	for <lustre-devel@archiver.kernel.org>; Mon, 20 Mar 2023 15:15:44 +0000 (UTC)
Received: from pdx1-mailman-customer002.dreamhost.com (localhost [127.0.0.1])
	by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTP id 4PgJF76Kx7z1yDk;
	Mon, 20 Mar 2023 08:14:51 -0700 (PDT)
Received: from mail-yw1-f180.google.com (mail-yw1-f180.google.com
 [209.85.128.180])
 (using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
 (No client certificate requested)
 by pdx1-mailman-customer002.dreamhost.com (Postfix) with ESMTPS id
 4PgJ4j4gH4z1yD2
 for <lustre-devel@lists.lustre.org>; Mon, 20 Mar 2023 08:07:33 -0700 (PDT)
Received: by mail-yw1-f180.google.com with SMTP id
 00721157ae682-5447d217bc6so229256447b3.7
 for <lustre-devel@lists.lustre.org>; Mon, 20 Mar 2023 08:07:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=gmail.com; s=20210112; t=1679324846;
 h=to:subject:message-id:date:from:mime-version:from:to:cc:subject
 :date:message-id:reply-to;
 bh=3tTU+x7jqjENzGTDKZKox3KlYTmAVikdEp64EH4lJI8=;
 b=HoD8pRU4mwFILWqJ11DOxQjdivtQsN/vNCaG1+DS4Tij8NTi1rcR6DVAdf5BLVmKNn
 Y1XENo2p0GE98V6C385g/ubwbKLu1phvCpFiLIBBPl+/QBjio/+mm7qALfh4Jj7XqtOJ
 fo8nGgypvFmXoUcFmt5R3K89jFs7zZXG2W21iNhBn1PwlQ23nV1QV0J8vou7T696OWN2
 MkYUl6swVq/iI6v7QkMDhXutZ9H9Ls2sq8Fwufjjf1pHMTN09nCUplWk85qcPYIepi+B
 jVjhKvRVrHHRdJhkvhbC0fwGYsEPmxPV5dAwU+TXN/lsDPpxFyIcePwYsMz7pHWqvAAS
 E56Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20210112; t=1679324846;
 h=to:subject:message-id:date:from:mime-version:x-gm-message-state
 :from:to:cc:subject:date:message-id:reply-to;
 bh=3tTU+x7jqjENzGTDKZKox3KlYTmAVikdEp64EH4lJI8=;
 b=K5IkFRYLPIXoK+c8nzDGkuTrMwmfocDUw+kv0yn5mw8TQm0TwO15zQD76eguUHLgX8
 C5ZPooNiRIgf85O4Lv7rmVZyGgN7kyPQ5dF2Jm58sqYMCYV0zR2TnYR19xyQXqMaCfnL
 JYkgkNB6UzNmfgEQPTdSltKIb73r7A3ThMNgqRn5QzY4iGzNOs0X4aJM7kzKCU/rTjhX
 hrQUqIoxxGZg9cgmEeUW7c8MqOtbb6+ezB2dQ5H1BoK7sX9SNBpOUU8axo3JYQGTqbQq
 z7AXTacVad3FDQ5zMnGrLDE5xoZyy1aJX+xP9iOAfsjmkrS6yBvqeUfSFKltY6K5LuBO
 MQJw==
X-Gm-Message-State: AO0yUKVq6FxRnPgGyDvPcAo9p4HhUl5WJJ6PfHPzsVBggqtx5DHSp0Ou
 WIJ+fiVi1dRYX4Z7ifYYJFsaDomyryhZcOwIDLdiK4jTRkA=
X-Google-Smtp-Source: AK7set+XWQjNIUIphUc4xnW3Snsh2D7g0iFiih2WMcJ3RuV1E+spKk65RB81TZK6GWFf4oO74ID0lB84PmO7KotVq/M=
X-Received: by 2002:a81:ae22:0:b0:533:9185:fc2c with SMTP id
 m34-20020a81ae22000000b005339185fc2cmr10519481ywh.7.1679324845219; Mon, 20
 Mar 2023 08:07:25 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 20 Mar 2023 09:07:14 -0600
Message-ID: <CAGfFL-yyvYfBieOVAr-ge9UxJedFWnq9zvnPA+t5baV8KDhYgw@mail.gmail.com>
To: Lustre Developement <lustre-devel@lists.lustre.org>
X-Mailman-Approved-At: Mon, 20 Mar 2023 08:14:39 -0700
Subject: [lustre-devel] Fwd: MSST 2023 Agenda and Registration
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
From: John Bent via lustre-devel <lustre-devel@lists.lustre.org>
Reply-To: John Bent <johnbent@gmail.com>
Content-Type: multipart/mixed; boundary="===============7760316386850801097=="
Errors-To: lustre-devel-bounces@lists.lustre.org
Sender: "lustre-devel" <lustre-devel-bounces@lists.lustre.org>

--===============7760316386850801097==
Content-Type: multipart/alternative; boundary="000000000000dca4f705f7564853"

--000000000000dca4f705f7564853
Content-Type: text/plain; charset="UTF-8"

All,

Please see below for information about the upcoming MSST in May. In
addition to many other excellent talks, Oleg Drokin from Whamcloud will be
discussing the Lustre write-back cache.

From: MSST-Conference <msst-conference-bounces@six.pairlist.net> on behalf
of: Sam Coleman <SamC@Webstart.com>
Date: Saturday, Mar 18, 2023 at 3:48 PM
To: msst-conference@six.pairlist.net <msst-conference@six.pairlist.net>
Subject: [EXTERNAL] MSST 2023 Agenda and Registration

MSST folks,

The MSST Planning Committee is excited to publish the agenda for the
upcoming 2023 MSST Conference, to take place during the week of May 22,
2023 at Santa Clara University. There will be four tutorials on Monday May
22 about file systems and metadata. The Invited Track runs on Tuesday May
23 and Wednesday May 24. Introduced by Erik Reidel's keynote about data's
impact on the environment, it includes twenty two talks from across the
industry, grouped into eight sessions. Several panels are planned and
breaks are provided to encourage the hallway conversations which have also
been a proud part of the MSST tradition. There is a mix of talks, ranging
from production systems to highly speculative research, and a few broader
perspective type analyses.

The program details can be found at our regular web site:
https://storageconference.us

Registration is open at:  https://commerce.cashnet.com/MSST23

Also, please reach out to the committee at any time with questions or
feedback, through our contact page:

https://storageconference.us/contact.html

We hope to see you in Santa Clara!

Sam

--000000000000dca4f705f7564853
Content-Type: text/html; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">All,<div><br></div><div>Please see below for information a=
bout the upcoming MSST in May. In addition to many other excellent talks, O=
leg Drokin from Whamcloud will be discussing the Lustre write-back cache.</=
div><div><br></div><div>From: MSST-Conference &lt;<a href=3D"mailto:msst-co=
nference-bounces@six.pairlist.net">msst-conference-bounces@six.pairlist.net=
</a>&gt; on behalf of: Sam Coleman &lt;SamC@Webstart.com&gt;<br>Date: Satur=
day, Mar 18, 2023 at 3:48 PM<br>To: <a href=3D"mailto:msst-conference@six.p=
airlist.net">msst-conference@six.pairlist.net</a> &lt;<a href=3D"mailto:mss=
t-conference@six.pairlist.net">msst-conference@six.pairlist.net</a>&gt;<br>=
Subject: [EXTERNAL] MSST 2023 Agenda and Registration<br><br>MSST folks,<br=
><br>The MSST Planning Committee is excited to publish the agenda for the u=
pcoming 2023 MSST Conference, to take place during the week of May 22, 2023=
 at Santa Clara University. There will be four tutorials on Monday May 22 a=
bout file systems and metadata. The Invited Track runs on Tuesday May 23 an=
d Wednesday May 24. Introduced by Erik Reidel&#39;s keynote about data&#39;=
s impact on the environment, it includes twenty two talks from across the i=
ndustry, grouped into eight sessions. Several panels are planned and breaks=
 are provided to encourage the hallway conversations which have also been a=
 proud part of the MSST tradition. There is a mix of talks, ranging from pr=
oduction systems to highly speculative research, and a few broader perspect=
ive type analyses.<br><br>The program details can be found at our regular w=
eb site: =C2=A0<a href=3D"https://storageconference.us">https://storageconf=
erence.us</a><br><br>Registration is open at: =C2=A0<a href=3D"https://comm=
erce.cashnet.com/MSST23">https://commerce.cashnet.com/MSST23</a><br><br>Als=
o, please reach out to the committee at any time with questions or feedback=
, through our contact page: <br><br><a href=3D"https://storageconference.us=
/contact.html">https://storageconference.us/contact.html</a><br><br>We hope=
 to see you in Santa Clara!<br><br>Sam<br></div></div>

--000000000000dca4f705f7564853--

--===============7760316386850801097==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
lustre-devel mailing list
lustre-devel@lists.lustre.org
http://lists.lustre.org/listinfo.cgi/lustre-devel-lustre.org

--===============7760316386850801097==--
